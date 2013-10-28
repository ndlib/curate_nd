# Generated via
#  `rails generate curate:work SeniorThesis`
require 'spec_helper'

describe CurationConcern::SeniorThesisActor do
  it_behaves_like(
    'is_a_curation_concern_actor',
    SeniorThesis,
    without_linked_resources: true,
    without_linked_contributors: true
  )
end
