require 'spec_helper'

describe "application/_announcements" do

  let(:current_user) { double }
  before(:each) do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(Admin::Announcement).to receive(:for).with(current_user).and_return(announcements)
  end

  context 'without announcements' do
    let(:announcements) { [] }

    it "renders an empty div" do
      render
      expect(rendered.strip).to eq "<div id=\"announcements\" class=\"container\">\n    <div class=\"row\">\n      <div class=\"span12 announcement-listing\">\n        <div class=\"announcement alert alert-info\">\n          <span class=\"announcement-text\">\n                ATTENTION: CurateND will become read-only on December 4, 2023 for an infrastructure update.</br>\n                We anticipate this update will be completed by the start of the new school semester in January 2024. </br></br>\n\n                Submissions cannot be accepted during this window while we upgrade to our new platform.</br>\n                Thank you for your patience.</br>\n                If you have any questions, contact the CurateND team at <a href=\"mailto:curate@nd.edu\">curate@nd.edu</a>.\n          </span>\n        </div>\n      </div>\n    </div>\n  </div>"
    end
  end

  context 'with announcements' do
    let(:announcements) { [FactoryGirl.build_stubbed(:admin_announcement)] }

    it "renders the announcments" do
      render
      expect(rendered).to have_tag('#announcements .announcement-listing .announcement') do
        with_tag(".announcement-dismiss", count: 1)
      end
    end
  end
end
