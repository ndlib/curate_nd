class Oai::QueryBuilder
  VALID_KEYS_AND_SEARCH_FIELDNAMES = {
    from: "desc_metadata__date_modified_dtsi",
    until: "desc_metadata__date_modified_dtsi",
    collection: "library_collections_pathnames_tesim",
    model: "active_fedora_model_ssi",
    primo: "primo",
  }.freeze
  VALID_SET_TYPE_SEARCHES = {
    collection: "und:",
    model: "type",
    primo: ""
  }

  def valid_request?(user_parameters)
    user_parameters.each do |term, value|
      (search_key, search_value) = search_terms_for(term, value)
      if VALID_KEYS_AND_SEARCH_FIELDNAMES[search_key].present?
        return false unless valid_value(search_key, search_value)
      end
    end
    return true
  end

  def build_filter_queries(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    user_parameters.each do |term, value|
      (search_key, search_value) = search_terms_for(term, value)
      if VALID_KEYS_AND_SEARCH_FIELDNAMES[search_key].present?
        Array.wrap(do_search_for(search_key, search_value)).each do |filter|
          solr_parameters[:fq] << filter
        end
      end
    end
    solr_parameters
  end

    private

    def search_terms_for(term, value)
      if term.to_sym == :set
        split_set_search(value)
      else
        [term.to_sym, value]
      end
    end

  # perform validations of the value of a search term
  def valid_value(key, value)
    case key
    when (:from || :until)
      return valid_date_format?(value)
    when :model || :collection
      return valid_set_type?(key, value)
    else
      # no value validation for key
      return true
    end
  end

  def filter_by_model(term)
    term
  end

  def filter_by_collection(term)
    term
  end

  def filter_by_primo(term)
    term
  end

  # allowed format: "2020-03-31T21:51:03Z"
  def filter_by_from(term)
    term.utc unless term.utc?
    "[#{term.xmlschema} TO *]"
  end

  # allowed format: "2020-03-31T21:51:03Z"
  def filter_by_until(term)
    term.utc unless term.utc?
    "[* TO #{term.xmlschema}]"
  end

  # builds filter query search for a given key & array of elements
  def do_search_for(key, value)
    search_term = self.send("filter_by_#{key}", value)
    prepare_search_term_for(key, search_term)
  end

  def prepare_search_term_for(key, term)
    field = VALID_KEYS_AND_SEARCH_FIELDNAMES[key]
    case field
    when "primo"
      return build_primo_set_search
    else
      this_term = field.ends_with?('dtsi') ? term : "\"#{term}\""
      return "#{field}:#{this_term}"
    end
  end

  def build_primo_set_search
    search_filter = []
    search_filter << "-desc_metadata__local_identifier_tesim:[* TO *]"
    search_filter << "-desc_metadata__alephIdentifier_tesim:[* TO *]"
    search_filter << "-active_fedora_model_ssi:Etd"
    search_filter << "-active_fedora_model_ssi:FindingAid"
    search_filter
  end

  def valid_date_format?(value)
    value.is_a?(Time)
  end

  def valid_set_type?(key, value)
    return false unless VALID_SET_TYPE_SEARCHES[key].present?
    return false if value.nil?
    return true if key == :collection && value.start_with(VALID_SET_TYPE_SEARCHES[key])
    return true if key == :model && valid_worktypes.include?(value)
    return true if key == :primo
    false
  end

  def split_set_search(value)
    (search_key, search_value) = value.split(':',2)
    new_value = begin
      if search_key == "primo"
        nil
      elsif search_value.start_with?("und:")
        search_value
      elsif valid_worktypes.include?(search_value.constantize)
        search_value.constantize
      else
        nil
      end
    rescue NameError
      nil
    end
    [search_key.to_sym, new_value]
  end

  def valid_worktypes
    @worktypes ||= Curate.configuration.registered_curation_concern_types.sort.collect(&:constantize)
  end
end
