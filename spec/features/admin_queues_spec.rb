require 'spec_helper'

require 'casclient'
require 'casclient/frameworks/rails/filter'

describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe 'admin queues behavior', describe_options do
  def with_javascript?
    @example.metadata[:js] || @example.metadata[:javascript]
  end

  before(:each) do
    Warden.test_mode!
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  after(:each) do
    Warden.test_reset!
    Resque.inline = @old_resque_inline_value
  end

  describe 'anonymous user' do
    it 'cannot see the /admin/queues' do
      visit('/admin/queues')
      expect(page).to have_tag('h1', text: 'Page Not Found')
      expect(page).to_not have_tag('h1', text: 'Queues')
    end
  end

  describe 'non-admin user' do
    let(:user) { FactoryGirl.create(:user) }
    it 'cannot see the /admin/queues' do
      login_as(user)
      visit('/admin/queues')
      expect(page).to have_tag('h1', text: 'Page Not Found')
      expect(page).to_not have_tag('h1', text: 'Queues')
    end
  end

  describe 'admin user' do
    # Making the assumption, that in test, an admin username is ENV['USER']
    let(:user) { FactoryGirl.create(:user, username: ENV['USER'].dup) }
    it 'cannot see the /admin/queues' do
      login_as(user)
      visit('/admin/queues')
      expect(page).to_not have_content('Page Not Found')
      expect(page).to have_tag('h1', text: 'Queues')
    end
  end
end