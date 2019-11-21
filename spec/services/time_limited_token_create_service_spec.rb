require 'spec_helper'

describe TimeLimitedTokenCreateService do
  let(:subject) { TimeLimitedTokenCreateService.new(noid: my_file.id, issued_by: user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:your_file) { FactoryGirl.create(:generic_file) }
  let(:my_file) { FactoryGirl.create(:generic_file, user: user) }
  let(:generic_work) { FactoryGirl.create(:generic_work, user: user) }

  context 'with no errors' do
    it 'creates a token and returns a hash' do
      expect{ subject.make_token }.to change(TemporaryAccessToken, :count).by(1)
      make_a_token = subject.make_token
      expect(make_a_token[:test]).to eq(:passed)
      expect(make_a_token[:valid]).to eq(true)
    end
  end

  context 'with errors' do
    context 'when file does not exist' do
      let(:subject) { TimeLimitedTokenCreateService.new(noid: 'abcde', issued_by: user) }

      it 'does not create a token and reports error' do
        expect{ subject.make_token }.not_to change(TemporaryAccessToken, :count)
        make_a_token = subject.make_token
        expect(make_a_token[:test]).to eq(:not_found)
        expect(make_a_token[:valid]).to eq(false)
      end
    end

    context 'when there is no user' do
      let(:subject) { TimeLimitedTokenCreateService.new(noid: my_file.id, issued_by: nil) }

      it 'does not create a token and reports error' do
        expect{ subject.make_token }.not_to change(TemporaryAccessToken, :count)
        make_a_token = subject.make_token
        expect(make_a_token[:test]).to eq(:no_user)
        expect(make_a_token[:valid]).to eq(false)
      end
    end

    context 'when user is unauthorized' do
      let(:subject) { TimeLimitedTokenCreateService.new(noid: your_file.id, issued_by: user) }

      it 'does not create a token and reports error' do
        expect{ subject.make_token }.not_to change(TemporaryAccessToken, :count)
        make_a_token = subject.make_token
        expect(make_a_token[:test]).to eq(:not_authorized)
        expect(make_a_token[:valid]).to eq(false)
      end
    end

    context 'when id is not a file' do
      let(:subject) { TimeLimitedTokenCreateService.new(noid: generic_work.id, issued_by: user) }

      it 'does not create a token and reports error' do
        expect{ subject.make_token }.not_to change(TemporaryAccessToken, :count)
        make_a_token = subject.make_token
        expect(make_a_token[:test]).to eq(:not_file)
        expect(make_a_token[:valid]).to eq(false)
      end
    end
  end

end
