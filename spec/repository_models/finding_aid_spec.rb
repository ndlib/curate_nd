require 'spec_helper'
require 'active_fedora/test_support'

describe FindingAid do
  include ActiveFedora::TestSupport
  subject { FindingAid.new }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'can_be_a_member_of_library_collections'

end
