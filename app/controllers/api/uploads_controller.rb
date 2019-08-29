require 'json'

class Api::UploadsController < Api::BaseController
  include Sufia::IdService # for mint method
  before_filter :set_current_user!, only: [:trx_initiate, :trx_new_file, :trx_append, :trx_commit]
  attr_reader :bucket

  # begin a new work transaction
  # GET /api/uploads/new
  def trx_initiate
    if @current_user
      trx_id = ApiTransaction.new_trx_id
      work_pid = mint_new_id
      metadata_formatter = Api::WorkMetadataFormatter.new(content: work_metadata_content_for(work_pid))
      # validate metadata
      if metadata_formatter.valid?
        # initiate transaction & upload files
        start_transaction = ApiTransaction.new(
          trx_id: trx_id,
          user_id: @current_user.id,
          work_id: work_pid,
          trx_status: ApiTransaction.set_status(:new)
        )
        # save transaction
        if start_transaction.save
          # write work metadata to s3 bucket connection
          bucket.put(
            named_path: "#{trx_id}/metadata-work-#{work_pid}.json",
            body: metadata_formatter.initial_metadata
          )
          # respond ok
          render json: { trx_id: trx_id,
                         work_id: work_pid },
                 status: :ok
        else # transaction save failed, error 417
          render json: { error: 'Transaction not initiated' },
                 status: :expectation_failed
        end
      else # invalid metadata, error 406
        render json: { error: 'Invalid metadata for work' },
               status: :not_acceptable
      end
    else # unauthenticated user, error 401
      render json: { error: 'Token is required to authenticate user' },
             status: :unauthorized
    end
  end

  # POST /api/uploads/:tid/file/new
  # Start a new upload of a file associated with this transaction
  def trx_new_file
    if @current_user
      trx_id = params[:tid]
      file_name = request.query_parameters[:file_name]
      work_pid = ApiTransaction.find(trx_id).work_id
      file_pid = mint_new_id
      next_sequence = next_file_sequence(trx_id: trx_id, file_id: file_pid)

      metadata_formatter = Api::FileMetadataFormatter.new(content: { file_name: file_name, file_id: file_pid, work_id: work_pid } )
      # validate metadata
      if metadata_formatter.valid?
        # write file from body of message to bucket
        bucket.put(
          named_path: "#{trx_id}/#{file_pid}-#{next_sequence}",
          body: request.body()
        )
        # write file metadata to bucket
        bucket.put(
          named_path: "#{trx_id}/metadata-file-#{file_pid}.json",
          body: metadata_formatter.initial_metadata
        )
        # update trx status
        update_status(trx_id: trx_id, status: :update)
        # respond ok
        render json: { trx_id: trx_id,
                       file_name: file_name,
                       file_id: file_pid,
                       sequence: next_sequence },
               status: :ok
      else # invalid metadata, error 406
        render json: { error: 'Invalid metadata for file' },
               status: :not_acceptable
      end
    else # unauthenticated user, error 401
      render json: { error: 'Token is required to authenticate user' },
             status: :unauthorized
    end
  end

  # POST /api/uploads/:tid/file/:fid
  # update next segment of a file
  def trx_append
    if @current_user
      trx_id = params[:tid]
      file_pid = params[:fid]
      next_sequence = next_file_sequence(trx_id: trx_id, file_id: file_pid)
      # write body of message to bucket
      bucket.put(
        named_path: "#{trx_id}/#{file_pid}-#{next_sequence}",
        body: request.body()
      )
      # respond ok
      render json: { trx_id: trx_id,
                    file_id: file_pid,
                    sequence: next_sequence },
             status: :ok
    else # unauthenticated user, error 401
      render json: { error: 'Token is required to authenticate user' },
             status: :unauthorized
    end
  end

  # GET /api/uploads/:tid/commit
  # submit for ingest
  def trx_commit
    if @current_user
      #parse out trx_id
      trx_id = params[:tid]
      #copy body of message to bucket
      bucket.put(
        named_path: "#{trx_id}/WEBHOOK",
        body: callback_url(trx_id: trx_id)
      )
      # update trx status
      update_status(trx_id: trx_id, status: :commit)
      # respond ok
      render json: { trx_id: trx_id }, status: :ok
    else # unauthenticated user, error 401
      render json: { error: 'Token is required to authenticate user' },
             status: :unauthorized
    end
  end

  # GET /api/uploads/:tid/status
  # Return status of this transaction
  def trx_status
    #parse out trx_id
    trx_id = params[:tid]

    begin
      status = ApiTransaction.find(trx_id).trx_status
      render json: { trx_id: trx_id, status: status }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { trx_id: trx_id, status: "Transaction not found" }, status: :not_found
    end
  end

  private

    def work_metadata_content_for(work_id)
      # comes in as json in request body
      content = request.body().to_s
      metadata_content = {}
      metadata_content = content if (!content.nil? && valid_json?(content))
      metadata_content[:work_id] = work_id
      metadata_content
    end

    def bucket
      @bucket ||= Api::StorageForIngest.new
    end

    def next_file_sequence(trx_id:, file_id:)
      next_sequence_nbr = ApiTransactionFile.next_seq_nbr(trx_id: trx_id, file_id: file_id)
      ApiTransactionFile.new(trx_id: trx_id, file_id: file_id, file_seq_nbr: next_sequence_nbr).save
      next_sequence_nbr
    end

    def update_status(trx_id:, status:)
      ApiTransaction.update(trx_id, trx_status: ApiTransaction.set_status(status))
    end

    def callback_url(trx_id:)
      # format is https://user_id_hash:trx_id_hash@localhost:3000/uploads/#{trx_id}/callback/ingest_completed.json
      File.join("#{request.protocol}#{trx_basic_auth}@#{request_domain}","/uploads/#{trx_id}/callback/ingest_completed.json")
    end

    def trx_basic_auth
      "#{Digest::MD5.hexdigest(@current_user.username)}:#{Digest::MD5.hexdigest(trx_id)}"
    end

    def request_domain
      return request.url.sub!(request.protocol, '').sub!(request.path, '')
    end

    def mint_new_id
      Sufia::Noid.noidify(Sufia::IdService.mint)
    end

    # identify bad json
    def valid_json?(json)
      JSON.parse(json)
       return true
      rescue JSON::ParserError => e
       return false
    end
end
