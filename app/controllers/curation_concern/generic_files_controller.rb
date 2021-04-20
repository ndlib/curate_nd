class CurationConcern::GenericFilesController < CurationConcern::BaseController
  include Curate::ParentContainer

  respond_to(:html)

  def attach_action_breadcrumb
    add_breadcrumb "#{parent.human_readable_type}", common_object_path(parent) unless parent.nil?
    super
  end

  before_filter :parent
  before_filter :cloud_resources_valid?, only: :create
  before_filter :authorize_edit_parent_rights!, except: [:show]

  self.excluded_actions_for_curation_concern_authorization = [:new, :create]
  def action_name_for_authorization
    (action_name == 'versions' || action_name == 'rollback') ? :edit : super
  end
  protected :action_name_for_authorization

  def cloud_resources_valid?
    if params.has_key?(:selected_files) && params[:selected_files].length>1
      respond_with(:curation_concern, curation_concern) do |wants|
        wants.html {
          flash.now[:error] = "Please select one cloud resource at a time."
          render 'new', status: :unprocessable_entity
        }
      end
      return false
    end
  end

  protected :cloud_resources_valid?

  self.curation_concern_type = GenericFile

  def new
    curation_concern.copy_permissions_from(parent)
    respond_with(curation_concern)
  end

  def create
    curation_concern.batch = parent
    if actor.create
      curation_concern.update_parent_representative_if_empty(parent)
      flash[:notice] = "You have uploaded a new file. We are processing it now."
      respond_with(:curation_concern, parent)
    else
      respond_with(:curation_concern, curation_concern) { |wants|
        wants.html { render 'new', status: :unprocessable_entity }
      }
    end
  end

  def show
    respond_with(curation_concern)
  end

  def edit
    if is_orphan_file?
      respond_with(:curation_concern, curation_concern) { |wants|
        wants.html { render show_tombstone_page, status: 410 }
      }
    else
      respond_with(curation_concern)
    end
  end

  def update
    if actor.update
      respond_with(:curation_concern, parent)
    else
      respond_with(:curation_concern, curation_concern) { |wants|
        wants.html { render 'edit', status: :unprocessable_entity }
      }
    end
  end

  def versions
    respond_with(curation_concern)
  end

  def rollback
    if actor.rollback
      respond_with(:curation_concern, curation_concern)
    else
      respond_with(:curation_concern, curation_concern) { |wants|
        wants.html { render 'versions', status: :unprocessable_entity }
      }
    end
  end

  def characterize_file
    Sufia.queue.push(CharacterizeJob.new(curation_concern.pid))
    redirect_to common_object_path(curation_concern)
  end

  def orphan
    parent_id = begin
      curation_concern.parent.id
    rescue
      "null"
    end
    result = OrphanFileService.orphan_file(file_id: curation_concern.pid, requested_by: current_user)
    notice = (result == true ? "File has been successfully orphaned from parent '#{ parent_id}'" : 'Unable to orphan this file')
    redirect_to common_object_path(curation_concern), notice: notice
  end

  register :actor do
    CurationConcern::Utility.actor(curation_concern, current_user, attributes_for_actor)
  end
end
