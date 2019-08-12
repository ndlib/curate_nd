class Api::UploadsController < ApplicationController

  # GET /api/uploads/new
  def new_transaction
    return_hash = {}
    return_hash['transaction_id'] = "trx_0001138"
    render json: return_hash.to_json
  end

  # POST /api/uploads/:tid/file/new
  def new_content
  end

  # POST /api/uploads/:tid/file/:fid
  def append_content
  end

  # POST /api/items
  def commit_transaction
  end

  private
    def enforce_show_permissions
      # do nothing. This overrides the method used in catalog controller which
      # re-routes show action to a log-in page.
    end
end
