class Api::DownloadsController < Api::BaseController
  prepend_before_filter :normalize_identifier, only: [:download]
  before_filter :validate_permissions!, only: [:download]

  # GET /api/items/download/1
  def download
    request_noid = Sufia::Noid.noidify(params[:id])
    download_noids = find_download_noids
    case download_noids.count
    when 0
      render json: { error: 'No authorized content' }, status: :expectation_failed
    when 1
      response.headers['X-Accel-Redirect'] = "/download-content/#{download_noids.first}"
      head :ok
    else
      response.headers['X-Accel-Redirect'] = "/download-content/#{request_noid}/zip/#{download_noids.join(',')}"
      head :ok
    end
  end

  private

    def find_download_noids
      solr_query_string = ActiveFedora::SolrService.construct_query_for_pids([params[:id]])
      solr_results = ActiveFedora::SolrService.query(solr_query_string)
      this_item = ActiveFedora::SolrService.reify_solr_results(solr_results).first
      # if item is a file, we have already validated authority, so just return noid
      return [Sufia::Noid.noidify(params[:id])] if this_item.is_a?(GenericFile)
      # if item is a work, we need to find all the generic files and check authority
      authorized_file_noids = []
      this_item.generic_files.each do |file|
        authorized_file_noids << Sufia::Noid.noidify(file.id) if @current_user.can? :read, file
      end
      authorized_file_noids
    end
end
