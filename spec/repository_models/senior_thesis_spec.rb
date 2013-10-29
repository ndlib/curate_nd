# Generated via
#  `rails generate curate:work SeniorThesis`
require 'spec_helper'
require 'active_fedora/test_support'

describe SeniorThesis do
  include ActiveFedora::TestSupport
  subject { SeniorThesis.new }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'
  it_behaves_like 'doi_assignable'
  it_behaves_like 'remotely_identified', :doi

end
