class Api::QueryBuilder
  VALID_KEYS_AND_SEARCH_FIELDNAMES = {
    type: ["active_fedora_model_ssi", "desc_metadata__type_tesim"],
    editor: ["edit_access_person_ssim"],
    depositor: ["depositor_tesim"],
    deposit_date: ["system_create_dtsi"],
    modify_date: ["system_modified_dtsi"],
  }.freeze

  AND_SEARCH_SEPARATOR = '^'
  OR_SEARCH_SEPARATOR = ','
  DATE_SEARCH_SEPARATOR = ':'
  DATE_SEARCH_TERMS = ['before', 'after']

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def valid_request?(user_parameters)
    user_parameters.each do |term, value|
      key = term.to_sym
      if VALID_KEYS_AND_SEARCH_FIELDNAMES[key].present?
        return false unless valid_value(key, value)
      end
    end
    return true
  end

  def build_filter_queries(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    user_parameters.each do |term, value|
      key = term.to_sym
      if VALID_KEYS_AND_SEARCH_FIELDNAMES[key].present?
        solr_parameters[:fq] << do_search_for(key, value)
      end
    end
    solr_parameters
  end

    private

  # perform validations of the value of a search term
  def valid_value(key, value)
    return false if value == "self" && @current_user.blank?
    case key
    when (:deposit_date || :modify_date)
      return valid_date_format?(value)
    else
      # no value validation for key
      return true
    end
  end

  def filter_by_type(term)
    term
  end

  def filter_by_editor(term)
    search_for_user = term
    if term == "self"
      search_for_user = current_user.username
    end
    search_for_user
  end

  def filter_by_depositor(term)
    search_for_user = term
    if term == "self"
      search_for_user = current_user.username
    end
    search_for_user
  end

  def filter_by_deposit_date(term)
    filter_by_date(term)
  end

  def filter_by_modify_date(term)
    filter_by_date(term)
  end

  # allowed formats: "after:2019-01-01", "before:2019-01-01", "2019-01-01"
  def filter_by_date(term)
    search_data = term.split(DATE_SEARCH_SEPARATOR)
    comparison_date = load_comparison_date(search_data.last)
    return "[#{comparison_date.xmlschema} TO *]" if search_data.first == DATE_SEARCH_TERMS.last
    return "[* TO #{comparison_date.xmlschema}]" if search_data.first == DATE_SEARCH_TERMS.first
    "[#{comparison_date.xmlschema.to_s} TO #{(comparison_date + 1.days).xmlschema}]"
  end

  # builds filter query search for a given key & array of elements
  def do_search_for(key, value)
    join_by = join_for(value)
    search_elements = parse_into_search_elements(key, value)
    filter = ""
    num_elements = search_elements.size
    search_elements.each_with_index do |term, x|
      search_term = self.send("filter_by_#{key}", term)
      filter += (prepare_search_term_for(key, search_term) + join_if_more(x, num_elements, join_by))
    end
    filter
  end

  def join_for(value)
    return " OR " if value.include?(OR_SEARCH_SEPARATOR)
    return " AND " if value.include?(AND_SEARCH_SEPARATOR)
  end

  # parse on special characters to build fq query
  # this allows us to have our own input interface
  def parse_into_search_elements(key, value)
    # separate value for "OR" search if it has a comma
    return Array.wrap(value.split(OR_SEARCH_SEPARATOR)) if value.include?(OR_SEARCH_SEPARATOR)
    # format value for "AND" search if it has '^'
    return Array.wrap(value.split(AND_SEARCH_SEPARATOR)) if value.include?(AND_SEARCH_SEPARATOR)
    # make sure returned value is an array
    Array.wrap(value)
  end

  def join_if_more(x, size, join_term)
    text = ""
    if x < size-1 # not last element
      text += join_term
    end
    text
  end

  def prepare_search_term_for(key, term)
    num_elements = VALID_KEYS_AND_SEARCH_FIELDNAMES[key].size
    search_term = ""
    VALID_KEYS_AND_SEARCH_FIELDNAMES[key].each_with_index do |field, x|
      this_term = field.ends_with?('dtsi') ? term : "\"#{term}\""
      search_term  += ("#{field}:#{this_term}" + join_if_more(x, num_elements, " OR "))
    end
    search_term
  end

  def load_comparison_date(input_date)
    ActiveSupport::TimeZone.new('UTC').parse(input_date)
  rescue ArgumentError
    nil
  end

  def valid_date_format?(value)
    # split search value at , or ^ between the and/or search values
    date_terms = value.split(AND_SEARCH_SEPARATOR).map{ |x| x.split(OR_SEARCH_SEPARATOR) }.flatten
    # validate each term, returning false when invalid term encountered
    date_terms.each do |term|
      # split at : to divide individual search term
      split_term = term.split(DATE_SEARCH_SEPARATOR)
      # return false if bad date format
      regex = /\d{4}-([1-9]\d|0?[1-9])-([1-9]\d|0?[1-9])/
      return false if (split_term.last =~ regex).nil?
      # return false if date parsing error occurs
      comparison_date = load_comparison_date(split_term.last)
      return false if comparison_date.nil?
      # return false if invalid 'before' or 'after' term
      if split_term.count > 1
        return false unless (DATE_SEARCH_TERMS.include?(split_term.first))
      end
    end
    # return true if all terms validate
    true
  end
end
