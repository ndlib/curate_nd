# Oai standards are different than HTTP standards.
# * standard HTTP codes are available for representing HTTP events
# * OAI error handling returns 200 when all is OK at HTTP level, along with
#   an OAI-PMH error to represent something wrong at the OAI-PMH level (e.g. badVerb, etc)
class OaiController < CatalogController
  self.solr_search_params_logic = [
    :default_solr_parameters,
    :add_query_to_solr,
    :add_paging_to_solr,
    :add_sorting_to_solr,
    :add_access_controls_to_solr_params,
    :enforce_embargo,
    :exclude_unwanted_models,
    :build_oai_query
  ]

  def index
    provider = CurateOaiProvider.new(controller: self)
    response = provider.process_request(oai_params.to_h)
    render body: response, content_type: "text/xml"
  end

  private

    def oai_params
      params.permit(:verb, :identifier, :metadataPrefix, :set, :from, :until, :resumptionToken)
    end

    def build_oai_query(solr_parameters, user_parameters)
      Oai::QueryBuilder.new.build_filter_queries(solr_parameters, user_parameters)
    end
end
