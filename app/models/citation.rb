class Citation
  include Rails.application.routes.url_helpers

  attr_reader :curation_concern, :authors, :title, :publishers

  class InvalidCurationConcern < RuntimeError
    def initialize(url_string)
      super(url_string)
    end
  end

  def initialize(curation_concern)
    @curation_concern = curation_concern
    @authors = authors_in_apa
    @title = title_in_apa
    @publishers = curation_concern.publisher.join(", ")
  end

  def to_s
    to_apa
  end

  def to_apa
    authors + published_date_in_apa + title + ". " + publishers + ". " + doi_apa
  end

  private

  def title_in_apa
    if curation_concern.title.blank?
      raise InvalidCurationConcern.new("Invalid Title!")
    end
    curation_concern.title
  end

  def authors_in_apa
    if curation_concern.authors_for_citation.blank?
      raise InvalidCurationConcern.new("Invalid Author!")
    end
    curation_concern.authors_for_citation.collect {|name| name_format(name.strip) }.to_sentence(:last_word_connector => ', & ', :two_words_connector => ', & ')
  end

  def name_format(name)
    normalized_name = Namae.parse(name).first
    "#{normalized_name.family}, #{given_name_in_apa(normalized_name.given)}"
  end

  def given_name_in_apa(name)
    initials_arr = name.split(" ").collect {|x| x.first}
    initials = ""
    initials_arr.each do |initial|
      initials << initial + "."
    end
    initials
  end

  def published_date_in_apa
    if curation_concern.created.blank?
      return " "
    end
    date = Date.parse(curation_concern.created)
    date.strftime("(%Y, %B %d). ")
  end

  def doi_apa
    curation_concern.identifier.nil? ? no_doi : curation_concern.identifier
  end

  def no_doi
    "Retrieved from #{File.join(Rails.configuration.application_root_url, common_object_path(curation_concern.to_param))}"
  end
end

