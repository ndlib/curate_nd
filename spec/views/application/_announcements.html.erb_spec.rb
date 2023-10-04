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
      expect(rendered.strip).to eq "<div id=\"announcements\" class=\"container\">\n    <div class=\"row\">\n      <div class=\"span12 announcement-listing\">\n        <div class=\"announcement alert alert-info\">\n          <span class=\"announcement-text\">\n                ATTENTION: CurateND will become read-only on November 1, 2023 for an infrastructure update.</br>\n                Submissions cannot be accepted at this time as we upgrade to a new platform.</br>\n                We anticipate this upgrade will be completed by December 8, 2023.  Thank you for your patience.</br>\n                If you have any questions, contact the CurateND team at <a href=\"mailto:curate@nd.edu\">curate@nd.edu</a>.</br>\n          </span>\n        </div>\n      </div>\n    </div>\n  </div>"
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
