module CurationConcern
  module IsMemberOfLibraryCollection
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :library_collections, property: :is_member_of_collection, class_name: "ActiveFedora::Base"
    end
  end
end
