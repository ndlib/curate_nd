require 'spec_helper'

module Devise::MultiAuth
  describe Authentication do
    let(:provider) { 'orcid' }
    let(:uid) { '0000-0002-1117-8571' }

    let(:attributes) {
      {
        "user_id"=>1,
        "provider"=>provider,
        "uid"=>uid,
        "access_token"=>"4a8e9a1a-e53a-448b-b81d-e541c347a711",
        "refresh_token"=>"b39b89ce-92df-4d99-bd25-309a869d201a"
      }
    }

    context '.to_access_token' do
      let(:client) { double('Client') }
      context 'with a created token'do
        before(:each) do
          described_class.create!(attributes)
        end
        subject { described_class.to_access_token(uid: uid, provider: provider, client: client) }
        it { should respond_to :get }
        it { should respond_to :post }
        it { should respond_to :refresh! }
        it { should respond_to :expires? }
        it { should respond_to :expires? }
      end

      context 'with a missing token' do
        it 'raises an error' do
          expect{ described_class.to_access_token(uid: uid, provider: provider, client: client) }.to raise_error(AccessTokenNotFound)
        end
      end
    end

    context '#to_access_token' do
      let(:client) { double('Client') }
      subject { described_class.new(attributes) }

      context 'without verified authentication' do
        its(:verified?) { should eq(true) }
        it { expect(subject.to_access_token(client: client)).to respond_to :get }
        it { expect(subject.to_access_token(client: client)).to respond_to :post }
        it { expect(subject.to_access_token(client: client)).to respond_to :refresh! }
        it { expect(subject.to_access_token(client: client)).to respond_to :expires? }
      end

      context 'without verified authentication' do
        subject { described_class.new(attributes) }
        let(:attributes) {
          {
            "user_id"=>1,
            "provider"=>provider,
            "uid"=>uid,
          }
        }
        its(:verified?) { should eq(false) }
        it {
          expect { subject.to_access_token(client: client) }.to raise_error(Devise::MultiAuth::AccessTokenUnverified)
        }
      end
    end

    context '.find_by_provider_and_uid' do
      it 'retrieves the object' do
        authentication = Authentication.create!(attributes)

        expect(described_class.find_by_provider_and_uid(provider, uid)).to eq(authentication)
      end
    end

    context '.find_user_by_provider_and_uid' do
      let(:user) {FactoryGirl.create(:user) }
      let(:authentication) { described_class.new(user: user) }

      it 'returns a user if it matches' do
        expect(described_class).to receive(:find_by_provider_and_uid).with(provider, uid).and_return(authentication)
        expect(
          described_class.find_user_by_provider_and_uid(provider, uid)
        ).to eq(user)
      end

      it 'returns nil if there are no match' do
        expect(described_class).to receive(:find_by_provider_and_uid).with(provider, uid).and_return(nil)
        expect(described_class.find_user_by_provider_and_uid(provider, uid)).to eq(nil)
      end

    end
  end
end
