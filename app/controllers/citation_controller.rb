class CitationController < ApplicationController
  include Hydra::Controller::ControllerBehavior

  respond_to :html, :json

  with_themed_layout '1_column'

  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier
  def curation_concern
    @curation_concern ||= ActiveFedora::Base.find(params[:id], cast: true)
  end
  before_filter :curation_concern
  helper_method :curation_concern

  def unauthorized_template
    'curation_concern/base/unauthorized'
  end

  STYLES = {
    apa: 'APA',
    mla: 'MLA',
    chicago: 'Chicago',
    harvard: 'Harvard',
    vancouver: 'Vancouver'
  }

  helper_method :result
  attr_accessor :result

  def show
    @result = {}
    citation = Citation.new(curation_concern)

    STYLES.keys.each do |style|
      citation_style = citation.make_citation(style)
      @result[style] = citation_style unless citation_style.nil?
    end

    render
  end

  def citation_label(style)
    STYLES[style]
  end
  helper_method :citation_label
end
