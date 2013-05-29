class Citation
  include Rails.application.routes.url_helpers

  def initialize(curation_concern)
    @curation_concern = curation_concern
  end

  def to_s
    to_apa
  end

  def to_apa
    authors_in_apa + published_date_in_apa + @curation_concern.title.strip + ". " + publishers_in_apa + ". " + doi_apa
  end

  def authors
    @curation_concern.authors_for_citation
  end

  private

  def authors_in_apa
    authors.collect {|name| name_format(name.strip) }.to_sentence(:last_word_connector => ', & ', :two_words_connector => ', & ')
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
    if @curation_concern.created.blank?
      return " "
    end
    date = Date.parse(@curation_concern.created)
    date.strftime("(%Y, %B %d). ")
  end

  def publishers_in_apa
    if @curation_concern.publisher.size == 1
      return @curation_concern.publisher.first
    end
    @curation_concern.publisher.join(", ")
  end

  def doi_apa
    @curation_concern.identifier.nil? ? no_doi : @curation_concern.identifier
  end

  def no_doi
    "Retrieved from #{File.join(Rails.configuration.application_url, common_object_path(@curation_concern.to_param))}"
  end
end

