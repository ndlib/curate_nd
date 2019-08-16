require 'aws-sdk-s3'
require 'json'

class Api::UploadsController < Api::BaseController
  include Sufia::IdService # for mint method
  before_filter :set_current_user!, only: [:trx_initiate, :trx_new_file]

  # GET /api/uploads/new
  def trx_initiate
    if @current_user
      trx_id = ApiTransaction.new_trx_id
      start_transaction = ApiTransaction.new(trx_id: trx_id, user_id: @current_user.id, trx_status: ApiTransaction.set_status(:new))
    end
    if @current_user && start_transaction.save
      render json: { trx_id: trx_id }, status: :ok
    else
      render json: { error: 'Transaction not initiated' }, status: :expectation_failed
    end
  end

  # POST /api/uploads/:tid/file/new
  # Start a new upload of a file associated with this transaction
  def trx_new_file
    if @current_user
      #parse out trx_id
      trx_id = params[:tid]

      #parse out file_name
      file_name = request.query_parameters[:file_name]
      #get a pid for the file
      file_pid = Sufia::Noid.noidify(Sufia::IdService.mint)
      # s3 bucket connection
      s3 = Aws::S3::Resource.new(region:'us-east-1')
      content = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/#{file_pid}-001")
      #copy body of message to bucket
      content.put(body: request.body())
      metadata = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/metadata-#{file_pid}.json")
      metadata.put(body: initial_file_metadata(file_name, file_pid))
      render json: { trx_id: trx_id, file_name: file_name, file_pid: file_pid, s3_bucket: ENV['S3_BUCKET'] }, status: :ok
    end
  end

  def trx_append
      render json: { error: 'Method trx_append not implemented' }, status: :ok
  end

  def trx_commit
      render json: { error: 'Method trx_commit not implemented' }, status: :ok
      end

  private

    def initial_file_metadata(file_name, file_pid)
      metadata_hash = {}
      metadata_hash[:pid] = "und:#{file_pid}"
      metadata_hash[:content_meta] = {}
      metadata_hash[:metadata] = {}
      metadata_hash[:content_meta][:label] = "#{file_name}"
      metadata_hash[:metadata]['dc:title'] = "#{file_name}"
      JSON.dump(metadata_hash)
    end
end
