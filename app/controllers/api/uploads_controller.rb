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
      if start_transaction.save
        render json: { trx_id: trx_id }, status: :ok
      else
        render json: { error: 'Transaction not initiated' }, status: :expectation_failed
      end
    else
      render json: { error: 'Token is required to authenticate user' }, status: :unauthorized
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
      next_sequence = next_file_sequence(trx_id: trx_id, file_id: file_pid)
      content = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/#{file_pid}-#{next_sequence}")
      #copy body of message to bucket
      content.put(body: request.body())
      metadata = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/metadata-#{file_pid}.json")
      metadata.put(body: initial_file_metadata(file_name, file_pid))

      # update trx status
      update_status(trx_id: trx_id, status: :update)

      render json: { trx_id: trx_id, file_name: file_name, file_pid: file_pid, sequence: next_sequence }, status: :ok
    else
      render json: { error: 'Token is required to authenticate user' }, status: :unauthorized
    end
  end

  # POST /api/uploads/:tid/file/:fid
  def trx_append
    if @current_user
      #parse out trx_id, file_id
      trx_id = params[:tid]
      file_id = params[:fid]
      # s3 bucket connection
      s3 = Aws::S3::Resource.new(region:'us-east-1')
      next_sequence = next_file_sequence(trx_id: trx_id, file_id: file_pid)
      content = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/#{file_pid}-#{next_sequence}")
      #copy body of message to bucket
      content.put(body: request.body())

      render json: { trx_id: trx_id, file_name: file_name, file_pid: file_pid, sequence: next_sequence }, status: :ok
    else
      render json: { error: 'Token is required to authenticate user' }, status: :unauthorized
    end
  end

  def trx_commit
    if @current_user
      #parse out trx_id
      trx_id = params[:tid]

      # s3 bucket connection
      s3 = Aws::S3::Resource.new(region:'us-east-1')
      content = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/WEBHOOK")
      #copy body of message to bucket
      content.put(body: callback_url(trx_id: trx_id))

      # update trx status
      update_status(trx_id: trx_id, status: :commit)

      # submit for ingest

      render json: { trx_id: trx_id }, status: :ok
    else
      render json: { error: 'Token is required to authenticate user' }, status: :unauthorized
    end
  end

  private

    def next_file_sequence(trx_id:, file_id:)
      next_sequence_nbr = ApiTransactionFile.next_seq_nbr(trx_id: trx_id, file_id: file_id)
      ApiTransactionFile.new(trx_id: trx_id, file_id: file_id, file_seq_nbr: next_sequence_nbr).save
      next_sequence_nbr
    end

    def update_status(trx_id:, status:)
      ApiTransaction.update(trx_id, trx_status: ApiTransaction.set_status(status))
    end

    def initial_file_metadata(file_name, file_pid)
      metadata_hash = {}
      metadata_hash[:pid] = "und:#{file_pid}"
      metadata_hash[:content_meta] = {}
      metadata_hash[:metadata] = {}
      metadata_hash[:content_meta][:label] = "#{file_name}"
      metadata_hash[:metadata]['dc:title'] = "#{file_name}"
      JSON.dump(metadata_hash)
    end

    def callback_url(trx_id:)
      # note: we probably want to create a new key of some sort, store it in the
      # ApiTransaction table, and not actually use the trx_id here
      trx_basic_auth = "#{username_for(trx_id: trx_id)}:#{trx_id}"

      # format is https://User Name:trx_authentication_key@localhost:3000/uploads/#{trx_id}/callback/ingest_completed.json
      File.join("https://#{trx_basic_auth}@#{request.domain}","/uploads/#{trx_id}/callback/ingest_completed.json")
    end

    def username_for(trx_id:)
      begin
        return ApiTransaction.find(trx_id).user.username
      rescue ActiveRecord::RecordNotFound
        return 'user not found'
      end
    end
end
