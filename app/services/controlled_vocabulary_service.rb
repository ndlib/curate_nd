require 'locabulary'

# Responsible for exposing means of looking up controlled vocabularies
class ControlledVocabularyService
  # @api public

  # @param name [String] - the predicate name to search
  # @param term_key [String] - the key to search
  # @param term_value [String] - the exact content to search for in the given key
  # @param ignore_not_found [Boolean] - true to suppress error
  # @return [<Locabulary::Items::Base>] - full item based on content of item's key and value
  def self.item_for_predicate_name(name:, term_key:, term_value:, ignore_not_found: false)
    begin
      Locabulary.item_for(predicate_name: name, search_term_key: term_key, search_term_value: term_value)
    rescue Locabulary::Exceptions::ItemNotFoundError => e
      Sentry.capture_exception(e) unless ignore_not_found
      return nil
    end
  end

  # @param name [String] - the predicate name to search
  # @return [Array of strings]
  # return array of all term_labels for a given predicate_name
  DEGREE_LEVELS = ["Senior Thesis", "Master's Thesis", "Doctoral Dissertation"].freeze
  def self.labels_for_predicate_name(name:)
    # degree levels are not handled via locabulary, as Curate's valid options
    # vary from Sipity's options.
    if name == 'degree_level'
      return DEGREE_LEVELS
    end
    Locabulary.all_labels_for(predicate_name: name)
  end

  # @param name [String] - the predicate name to search
  # @param name [Time] - active as of date
  # @return [Array<Locabulary::Items::Base>] - active full items for a given predicate_name
  def self.active_entries_for_predicate_name(name:, as_of: Time.zone.now)
    Locabulary.active_items_for(predicate_name: name, as_of: as_of)
  end

  # @param name [String] - the predicate name to search
  # @return [Array<Locabulary::Items::Base>] - all full items for a given predicate_name
  def self.all_entries_for_predicate_name(name:)
    Locabulary.all_items_for(predicate_name: name)
  end

  # @param name [String] - the predicate name to search
  # @param uri [] - the predicate name to search
  # @return [String] - labels for a given predicate_name and uri
  def self.label_from_uri(name:, uri:)
    Locabulary.active_label_for_uri(predicate_name: name, term_uri: uri)
  end

  # @param name [String] - the predicate name to search
  # @param as_of [Time] - active as of date or :all
  # @return [Array<Locabulary::Items] - Array of Locabulary items
  def self.active_hierarchical_roots(name:, as_of: Time.zone.now)
    Locabulary.active_hierarchical_roots(predicate_name: name, as_of: as_of)
  end

  # @param roots [Array<Locabulary::Items] - returned from active_hierarchical_roots
  # @return [Array<Hash] - Formatted hashes for admin unit selection menu
  def self.hierarchical_menu_options(roots:)
    Locabulary.hierarchical_menu_options(roots: roots)
  end

  # @param name [String] - the predicate name to search
  # @param items [Array] list of Blacklight::SolrResponse::Facets::FacetItem
  # @param delimiter [String] - a character used as delimiter
  # @return [Array] - Array of Locabulary items
  def self.build_ordered_hierarchical_tree(name:, items:, delimiter:)
    Locabulary.build_ordered_hierarchical_tree(
      faceted_items: items,
      faceted_item_hierarchy_delimiter: delimiter,
      predicate_name: name
    )
  end
end
