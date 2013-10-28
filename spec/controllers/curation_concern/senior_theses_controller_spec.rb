# Generated via
#  `rails generate curate:work SeniorThesis`
require 'spec_helper'

describe CurationConcern::SeniorThesesController do
  it_behaves_like 'is_a_curation_concern_controller', SeniorThesis, actions: :all
end
