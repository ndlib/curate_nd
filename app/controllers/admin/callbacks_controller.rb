module Admin
  class CallbacksController < ApplicationController
  respond_to :jsonld
  before_filter :validate_authentication
  attr_reader :validated

    # The WEBHOOK posts the following JSON body:
    # ```json
    #   { "host" : "libvirt8.library.nd.edu", "version" : "1.0.1", "job_name" : "ingest-45", "job_state" : "success" }
    # ```
    # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md

    # params: {"controller"=>"admin/callbacks", "action"=>"callback_response", "tid"=>"c7af186a8d75c44a", "response"=>"ingest_completed", "format"=>"json"}

    def callback_response
      trx_id = params[:tid]
      response = params[:response]

      if validated
        response_data = JSON.parse(request.body.read)
        updated = update_transaction_status_based_on(trx_id: trx_id, ingest_status: response_data["job_state"])

        if updated
          render json: { trx_id: trx_id, ingest_response: response_data["job_state"] }, status: :ok
        else
          render json: { trx_id: trx_id, ingest_response: response_data["job_state"], callback_response: "status update failed" }, status: :not_modified
        end

      else
        render json: { trx_id: trx_id, callback_response: "unauthorized callback" }, status: :unauthorized
      end
    end

    private

    def validate_authentication
      @validated = authenticate_with_http_basic do |user, pass|
        Api::CallbackTrxValidator.new(trx_id: params[:tid],
                                      user_name_hash: user,
                                      trx_id_hash: pass).validate
      end
      @validated
    end

    def update_transaction_status_based_on(trx_id:, ingest_status:)
      # "processing" is not recorded to database and not an error
      return true if ingest_status == 'processing'
      ApiTransaction.set_status_based_on(trx_id: trx_id, action: ingest_status.to_sym)
    end
  end
end
