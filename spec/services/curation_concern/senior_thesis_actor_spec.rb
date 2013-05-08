require 'spec_helper'

describe CurationConcern::SeniorThesisActor do
  let(:pid) { CurationConcern.mint_a_pid }
  let(:user) { FactoryGirl.create(:user) }
  let(:curation_concern) { SeniorThesis.new(pid: pid)}
  let(:assigned_doi) { 'abc-123' }
  let(:mock_doi_minter) {
    lambda {|pid|
      object = ActiveFedora::Base.find(pid, cast: true)
      object.identifier = assigned_doi
      object.save
      true
    }
  }

  subject {
    CurationConcern.actor(curation_concern, user, attributes)
  }

  before(:each) {
    subject.doi_minter = mock_doi_minter
  }

  describe '#create' do

    describe 'invalid attributes' do
      let(:visibility) { AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      let(:attributes) {
        FactoryGirl.attributes_for(:senior_thesis_invalid).tap {|a|
          a[:visibility] = visibility
        }
      }
      it 'remembers the input visibility' do
        expect {
          expect {
            expect{
              subject.create!
            }.to raise_error(ActiveFedora::RecordInvalid)
          }.to change(curation_concern, :visibility).from(nil).to(visibility)
        }.to change(curation_concern, :authenticated_only_access?).from(false).to(true)
      end
    end
    describe 'valid attributes' do
      let(:files) { [] }
      let(:visibility) { AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      let(:attributes) {
        FactoryGirl.attributes_for(:senior_thesis).tap {|a|
          a[:files] = files
          a[:visibility] = visibility
          a[:assign_doi] = '1'
        }
      }

      describe 'with one file' do
        let(:files_path) { __FILE__ }
        let(:files) { Rack::Test::UploadedFile.new(files_path, 'text/plain', false)}
        before(:each) do
          subject.create!
        end

        describe 'authenticated visibility' do
          it 'handles one file' do
            expect(curation_concern).to be_persisted
            curation_concern.date_uploaded.should == Date.today
            curation_concern.date_modified.should == Date.today
            curation_concern.depositor.should == user.user_key

            new_curation_concern = curation_concern.class.find(curation_concern.pid)

            new_curation_concern.generic_files.count.should == 1
            # Sanity test to make sure the file we uploaded is stored and has same permission as parent.
            senior_files = new_curation_concern.generic_files.first
            senior_files.content.content.should == files.read
            senior_files.filename.should == File.basename(files_path)

            expect(new_curation_concern).to be_authenticated_only_access
            expect(senior_files).to be_authenticated_only_access
            expect(new_curation_concern.identifier).to eq(assigned_doi)
          end
        end

        describe 'embargoed file' do

          let(:visibility) { AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
          let(:formatted_embargo_release_date) { 2.days.from_now.strftime('%Y-%m-%d') }
          let(:attributes) {
            FactoryGirl.attributes_for(:senior_thesis).tap {|a|
              a[:files] = files
              a[:visibility] = visibility
              a[:embargo_release_date] = formatted_embargo_release_date
              a[:assign_doi] = '1'
            }
          }

          it 'stamps embargo information on files' do
            reloaded_curation_concern = curation_concern.class.find(curation_concern.pid)
            expect(reloaded_curation_concern).to be_open_access_with_embargo_release_date
            expect(reloaded_curation_concern.embargo_release_date).to eq(formatted_embargo_release_date)
            reloaded_curation_concern.generic_files.each do |file|
              expect(file.embargo_release_date).to eq(formatted_embargo_release_date)
              expect(file).to be_open_access_with_embargo_release_date
            end
          end
        end

        describe 'with two or more files' do
          let(:files) { [file_1, file_2, file_3]}
          let(:file_1) { Rack::Test::UploadedFile.new(__FILE__, 'text/plain', false) }
          let(:file_2) { Rack::Test::UploadedFile.new(File.expand_path('../../../spec_helper.rb', __FILE__), 'text/plain', false) }
          let(:file_3) { Rack::Test::UploadedFile.new(File.expand_path('../../../../Gemfile', __FILE__), 'text/plain', false) }
          it "creates both files" do
            new_curation_concern = curation_concern.class.find(curation_concern.pid)
            new_curation_concern.generic_files.count.should == files.length
          end
        end
      end
    end

    describe '#update' do
      let(:files_path) { __FILE__ }
      let(:files) { [Rack::Test::UploadedFile.new(files_path, 'text/plain', false)] }

      before(:each) {
        subject.doi_minter = mock_doi_minter
      }

      let(:attributes) {
        FactoryGirl.attributes_for(:senior_thesis).tap {|a|
          a[:visibility] = AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          a[:assign_doi] = '1'
          a[:files] = files
        }
      }
      describe 'valid attributes' do
        before(:all) do
          curation_concern.apply_depositor_metadata(user.user_key)
        end
        it do
          subject.update!
          expect(curation_concern.identifier).to be_blank
          expect(curation_concern).to be_persisted
          expect(curation_concern).to be_open_access
          new_curation_concern = curation_concern.class.find(curation_concern.pid)
          expect(new_curation_concern.identifier).to eq(assigned_doi)
          expect(new_curation_concern.generic_files.count).to eq(1)
          generic_file = new_curation_concern.generic_files.first
          generic_file.content.content.should == files.first.read
          generic_file.filename.should == File.basename(files_path)
        end
      end
    end

  end
end
