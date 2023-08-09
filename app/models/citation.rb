require 'citeproc'
require 'csl/styles'

class Citation
  include Rails.application.routes.url_helpers

  # maps our internal name to the citeproc style name
  STYLES = {
    apa: "apa",
    mla: "modern-language-association-7th-edition-underline",
    chicago: "chicago-author-date-16th-edition",
    harvard: "harvard-cite-them-right",
    bibtex: "bibtex"
  }

  attr_reader :curation_concern, :item

  def initialize(curation_concern)
    @curation_concern = curation_concern
    @item = build_item
  end

  # The view code expects this to return an APA citation
  def to_s
    make_citation(:apa)
  end

  # return html formatted citation in the given style
  def make_citation(style)
    cp = CiteProc::Processor.new(style: STYLES[style], format: 'html')
    cp.engine.format = 'html'
    cp << item
    return nil if item.nil?
    result = cp.render(:bibliography, id: item.id, format: 'html')
    # render returns a list
    result.first
  end

  private

  # the item information we pass to citeproc
  def build_item
    begin
      show_page = common_object_url(curation_concern.noid, host:Rails.configuration.application_root_url)
      md = {
        id: curation_concern.noid,
        URL: show_page,
        source: show_page,
        title: curation_concern.title,
      }
      # see https://github.com/inukshuk/citeproc/blob/master/lib/citeproc/variable.rb for valid variables in item
      val = date_created
      md[:issued] = val if val.present?
      val = creator
      md[:author] = val if val.present?
      val = publisher
      md[:publisher] = val if val.present?
      val = doi
      md[:DOI] = val if val.present?
      val = item_type
      md[:type] = val if val.present?
      CiteProc::Item.new(md)
    rescue TypeError => e
      
      nil
    end
  end

  # map to valid item types from https://github.com/inukshuk/citeproc/blob/master/lib/citeproc/item.rb
  ITEM_TYPE_MAP = {
    "Article": :article,
    "Doctoral Dissertation": :thesis,
    "Master's Thesis": :thesis,
    "Senior Thesis": :thesis,
    "Patent": :patent,
    "Manuscript": :manuscript,
    "Pamphlet": :pamphlet,
    "Book Chapter": :chapter,
    "Book": :book,
    "Image": :graphic,
    "Capstone Project": :thesis,
    "Master of Architecture": :thesis

        # Valid types:
        # :article, :'article-journal', :'article-magazine', :'article-newspaper',
        # :bill, :book, :broadcast, :chapter, :entry, :'entry-dictionary',
        # :'entry-encyclopedia', :figure, :graphic, :interview, :legal_case,
        # :legislation, :manuscript, :map, :motion_picture, :musical_score,
        # :pamphlet, :'paper-conference', :patent, :personal_communication, :post,
        # :'post-weblog', :report, :review, :'review-book', :song, :speech,
        # :thesis, :treaty, :webpage
  }.freeze
  def item_type
    val = try_fields([:human_readable_type])
    return nil if val.blank?
    # will be nil if val not found
    ITEM_TYPE_MAP[val.to_sym]
  end

  def doi
    val = try_fields([:doi, :identifier])
    return nil if val.blank?
    if val.respond_to?(:select)
    # try to only keep dois
      val = val.select { |id| id =~ /\A[^0-9]*?10\./ }.first
    end
    # remove any doi: prefixes
    val.sub(/\A.*?10/, "10")
  end

  def date_created
    val = try_fields([:date_created, :created, :publication_date])
    return nil if val.blank?
    return val if val.is_a? Date
    # In collections, the date is an array
    val = Array.wrap(val).first
    begin
      Date.parse(val)
    rescue ArgumentError => e
      
      nil
    end
  end

  def creator
    val = try_fields([:creator, :author])
    return nil if val.nil?
    val.join(" and ")
  end

  def publisher
    val = try_fields([:publisher])
    return nil if val.nil?
    val.join(", ")
  end

  def try_fields(fields)
    fields.each do |field|
      if curation_concern.respond_to?(field)
        return curation_concern.send(field)
      end
    end
    nil
  end
end
