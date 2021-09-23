class OrphanFileRequestsController < ApplicationController
    SUCCESS_NOTICE = "Your file deletion request has been submitted and should be processed within 5 business days. If you have any questions or concerns, please contact the CurateND team at: curate@nd.edu"
    UNAUTHORIZED_NOTICE = "You do not have the authority to make this request. Please contact the CurateND team for assistance at: curate@nd.edu"
    FAILURE_NOTICE = "Unable to process this request. Please contact the CurateND team for assistance at: curate@nd.edu"
    with_themed_layout

    attr_reader :file_to_orphan, :parent_work, :file_id
    respond_to(:html)
  
    def orphan_file_request
      @orphan_file_request ||= build_orphan_file_request
    end
    helper_method :orphan_file_request

    def new
      if current_ability.cannot? :edit, file_to_orphan
        redirect_to common_object_path(file_to_orphan), notice: UNAUTHORIZED_NOTICE
      end
      parent_work
      orphan_file_request
    end
  
    def create
      if orphan_file_request.save
        redirect_to common_object_path(parent_work), notice: SUCCESS_NOTICE 
      else
        redirect_to common_object_path(file_to_orphan), notice: FAILURE_NOTICE
      end
    end
  
    private
  
    def build_orphan_file_request
      if params[:action] == 'new'
        return OrphanFileRequest.new(file_id: params[:file_id])
      else
        return OrphanFileRequest.new(create_orphan_file_params)
      end
    end

    def create_orphan_file_params
      params.require(:orphan_file_request).permit(
        :file_id,
        :work_id,
        :user_id,
        :user_email,
        :completed_date,
        :updating_user_id
      )
    end

    def file_to_orphan
      @file_to_orphan ||= load_file
      end

    def parent_work
      @parent_work ||= load_parent_work(file_to_orphan) if file_to_orphan
    end

    def load_file
      noid = normalize(file_id)
      begin
        GenericFile.find(noid)
      rescue ActiveFedora::ObjectNotFoundError
        nil
      end
    end

    def load_parent_work(file)
      begin
        file.parent
      rescue
        nil
      end
    end

    def normalize(id)
      Sufia::Noid.namespaceize(id)
    end

    def file_id
      return params[:file_id] if params.has_key?(:file_id)
      params[:orphan_file_request][:file_id]
    end
  end