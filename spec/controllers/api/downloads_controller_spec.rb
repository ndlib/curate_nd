require 'spec_helper'

describe Api::DownloadsController do
  let(:generic_work_with_files) { FactoryGirl.create(:generic_work_with_files, title: 'I have 3 files', user: user) }
  let(:generic_file) { FactoryGirl.create(:generic_file, user: user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }

  describe '#download' do
    context 'with authority to item' do
      context 'when item is a work with several files' do
        it 'has X-Accel-Redirect header to download zip files in response' do
          request.headers['X-Api-Token'] = token.sha
          request.headers['HTTP_ACCEPT'] = "application/json"
          get :download, { id: generic_work_with_files.to_param }
          file_list = generic_work_with_files.generic_files.map{|file| Sufia::Noid.noidify(file.id) }
          expect(response.headers.fetch('X-Accel-Redirect')).to eq("/download-content/#{generic_work_with_files.to_param}/zip/#{file_list.join(',')}")
        end
      end

      context 'when item is a generic file' do
        it 'has X-Accel-Redirect header to single download in response' do
          request.headers['X-Api-Token'] = token.sha
          request.headers['HTTP_ACCEPT'] = "application/json"
          get :download, { id: generic_file.to_param }
          expect(response.headers.fetch('X-Accel-Redirect')).to eq("/download-content/#{generic_file.to_param}")
        end
      end
    end

    context 'without authority to item' do
      it 'returns 403 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :download, { id: generic_file.to_param }
        expect(response).to be_forbidden
      end
    end

    context 'with file not found' do
      it 'returns 404 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :download, { id: "abcdefg" }
        expect(response).to be_not_found
      end
    end
  end
end
