module Admin
  class CallbacksController < ApplicationController
  respond_to :jsonld
  before_filter :validate_authentication
  attr_reader :trx_id, :validated

    # The WEBHOOK posts the following JSON body:
    # ```json
    #   { "host" : "libvirt8.library.nd.edu", "version" : "1.0.1", "job_name" : "ingest-45", "job_state" : "success" }
    # ```
    # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md

    # params: {"controller"=>"admin/callbacks", "action"=>"callback_response", "tid"=>"c7af186a8d75c44a", "response"=>"ingest_completed", "format"=>"json"}

    def callback_response
      response = params[:response]

      if validated
        response_data = JSON.parse(request.body.read)
        update_transaction_status_based_on(trx_id: trx_id, ingest_status: response_data["job_state"])

        render json: { trx_id: trx_id, ingest_response: response_data["job_state"] }, status: :ok
      else
        render json: { trx_id: trx_id, callback_response: "unauthorized callback" }, status: :unauthorized
      end
    end

    private

    def validate_authentication
      @validated = authenticate_with_http_basic do |user, pass|
        authenticate_trx(user_name_hash: user, trx_id_hash: pass)
      end
      @validated
    end

    def update_transaction_status_based_on(trx_id:, ingest_status:)
      case ingest_status
      when "success"
        ApiTransaction.update(trx_id, trx_status: ApiTransaction.set_status(:complete))
      when "error"
        ApiTransaction.update(trx_id, trx_status: ApiTransaction.set_status(:error))
      when "processing"
        # do nothing
      else
        # do nothing
      end
    end

    def authenticate_trx(user_name_hash:, trx_id_hash:)
      @trx_id = params[:tid]
      return false unless trx_id
      return false unless user_name_hash
      return false unless trx_id_hash
      begin
        trx_user = ApiTransaction.find(trx_id).user.username
      rescue ActiveRecord::RecordNotFound
        return false
      end
      return true if (Digest::MD5.hexdigest(trx_id) == trx_id_hash && Digest::MD5.hexdigest(trx_user) == user_name_hash)
      false
    end
  end
end
