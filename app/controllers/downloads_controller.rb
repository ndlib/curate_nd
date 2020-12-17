require 'sufia/models/noid'

class DownloadsController < ApplicationController
  include Sufia::Noid # for normalize_identifier method

  # ***************************************************************************
  # begin include Hydra::Controller::DownloadBehavior
  def self.default_content_dsid
    "content"
  end

  before_filter :load_asset
  before_filter :load_datastream

  # Responds to http requests to show the datastream
  def show
    if can_download?
      if datastream.new?
        render_404
      else
        # we can now examine asset and determine if we should send_content, or some other action.
        if is_orphan_file? && cannot_view_orphans?
          render show_tombstone_page, status: 410
        else
          send_content(asset)
        end
      end
    else
      logger.info "Can not read #{params[asset_param_key]}"
      raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which has been marked private.", :read, params[asset_param_key])
    end
  end

  protected

  # Override this method if asset PID is not passed in params[:id],
  # for example, in a nested resource.
  def asset_param_key
    :id
  end

  def load_asset
    @asset = ActiveFedora::Base.load_instance_from_solr(params[asset_param_key])
  end

  def load_datastream
    @ds = datastream_to_show
  end

  def asset
    @asset
  end

  def datastream
    @ds
  end

  # Override this if you'd like a different filename
  # @return [String] the filename
  def datastream_name
    params[:filename] || asset.label
  end

  # render an HTTP HEAD response
  def content_head
    response.headers['Content-Length'] = datastream.dsSize
    response.headers['Content-Type'] = datastream.mimeType
    head :ok
  end

  # render an HTTP Range response
  def send_range
    _, range = request.headers['HTTP_RANGE'].split('bytes=')
    from, to = range.split('-').map(&:to_i)
    to = datastream.dsSize - 1 unless to
    length = to - from + 1
    response.headers['Content-Range'] = "bytes #{from}-#{to}/#{datastream.dsSize}"
    response.headers['Content-Length'] = "#{length}"
    self.status = 206
    send_file_headers! content_options
    self.response_body = datastream.stream(from, length)
  end

  private

  def default_content_ds
    ActiveFedora::ContentModel.known_models_for(asset).each do |model_class|
      return asset.datastreams[model_class.default_content_ds] if model_class.respond_to?(:default_content_ds)
    end
    if asset.datastreams.keys.include?(DownloadsController.default_content_dsid)
      return asset.datastreams[DownloadsController.default_content_dsid]
    end
  end
  # end include Hydra::Controller::DownloadBehavior
  # ***************************************************************************

  include Hydra::AccessControls
  prepend_before_filter :normalize_identifier, except: [:index, :new, :create]
  with_themed_layout

  rescue_from Hydra::AccessDenied, with: :handle_access_denied

  # Override this method to change which datastream is shown.
  # Loads the datastream specified by the HTTP parameter `:datastream_id`.
  # If this object does not have a datastream by that name, return the default datastream
  # as returned by {#default_content_ds}
  # @return [ActiveFedora::Datastream] the datastream
  def datastream_to_show
    ds = asset.datastreams[params[:datastream_id]] if params.has_key?(:datastream_id)
    ds = default_content_ds if ds.nil?
    raise "Unable to find a datastream for #{asset}" if ds.nil?
    ds
  rescue Exception => e
    raise e unless params[:datastream_id] == 'thumbnail'
    respond_with_default_thumbnail_image
    return false
  end

  protected

  def render_404
    if params[:datastream_id] == 'thumbnail'
      respond_with_default_thumbnail_image
    else
      render '/errors/404'
    end
  end

  # Send default thumbnail image
  def respond_with_default_thumbnail_image
    image= ActionController::Base.helpers.asset_path("curate/default.png", type: :image)
    redirect_to image
  end

  def content_options
    options = {
      disposition: 'inline',
      type: datastream.mimeType,
      filename: datastream_name
    }
    options[:disposition] = 'attachment' if options[:type] =~ /\/xml/i
    options
  end

  def send_content(asset)
    # Disadis is configured to send only content datastreams. Don suggested that
    # we leave thumbnails to the application for the time being.
    if download_proxying_enabled? && !thumbnail_datastream?
      response.headers['X-Accel-Redirect'] = "/download-content/#{asset.noid}"
      head :ok
    else
      response.headers['Accept-Ranges'] = 'bytes'

      if head_request?
        content_head
      elsif range_request?
        send_range
      else
        if redirect_datastream?
          redirect_to datastream.dsLocation
        else
          # So I'm not querying the datastream multiple times.
          copy_of_content_options = content_options

          # If we have a thumbnail request, but for some reason the thumbnail derivative
          # was not generated, if we were to attempt to send file headers without a :type,
          # an exception would be thrown.
          if thumbnail_datastream? && copy_of_content_options[:type].nil?
            logger.error("ERROR: Unable to render thumbnail datastream for #{datastream.pid}")
            respond_with_default_thumbnail_image
          else
            send_file_headers! copy_of_content_options
            self.response_body = datastream.stream
          end
        end
      end
    end
  end

  private

  def can_download?
    if params[:token] && TemporaryAccessToken.permitted?(Sufia::Noid.noidify(params[:id]), params[:token])
      TemporaryAccessToken.use!(params[:token])
      true
    else
      # The original logic was `super`, which expanded to `can? :read, datastream.pid`
      # However, since asset is in theory loaded as part of the before_filter, I'm relying
      # on that to not duplicate the underlying load_instance_from_solr that could happen in the
      # permission system.
#      can? :read, @asset || load_asset
      true
    end
  end

  def download_proxying_enabled?
    Rails.application.config.use_proxy_for_download.enabled?
  end

  def handle_access_denied
    if thumbnail_datastream?
      asset = load_asset
      if can_download_thumnail?(asset)
        send_content (asset)
      else
        respond_with_default_thumbnail_image
        return false
      end
    else
      if current_user
        error_code = '403'
      else
        error_code = '401'
      end
      respond_to do |format|
        format.json { render json: { status: 'ERROR', code: error_code }, status: error_code }
        format.html { render "/errors/#{error_code}", status: error_code }
      end
    end
  end

  def head_request?
    request.head?
  end

  def range_request?
    request.headers['HTTP_RANGE']
  end

  def redirect_datastream?
    datastream.redirect?
  end

  def redirect_url
    datastream.dsLocation
  end

  def thumbnail_datastream?
    params[:datastream_id] == 'thumbnail'
  end

  def can_download_thumnail?(asset)
    return nd_only_datastream? && (can? :read, asset.parent.pid)
  end

  def nd_only_datastream?
    permissions = current_ability.permissions_doc(params[:id])
    access_key = ActiveFedora::SolrService.solr_name("read_access_group", Hydra::Datastream::RightsMetadata.indexer)
    return permissions[access_key].present? && permissions[access_key].first.downcase == "registered"
  end

  def cannot_view_orphans?
    return false if RepoManager.with_active_privileges?(current_user)
    true
  end

  def is_orphan_file?
    return true if asset.is_a?(GenericFile) && asset.parent.nil?
    false
  end

  def show_tombstone_page
    'curation_concern/generic_files/tombstone'
  end
end
