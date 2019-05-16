require File.expand_path('../../helpers/common_objects_helper', __FILE__)
class CommonObjectsController < ApplicationController
  append_view_path(Rails.root.join('app/views/curation_concern/base'))
  include Hydra::Controller::ControllerBehavior
  layout 'common_objects'

  respond_to(:html, :jsonld)
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier
  def curation_concern
    @curation_concern ||= ActiveFedora::Base.find(params[:id], cast: true)
  end
  before_filter :curation_concern
  helper_method :curation_concern
  helper CommonObjectsHelper

  def unauthorized_template
    'curation_concern/base/unauthorized'
  end

  before_filter :enforce_show_permissions, only: [:show]
  rescue_from Hydra::AccessDenied do |exception|
    respond_with curation_concern do |format|
      format.html { render unauthorized_template, status: 401 }
      format.jsonld { render json: { error: 'Unauthorized' }, status: 401 }
    end
  end

  # Overriding this from Hydra::AccessControlsEnforcement.
  # The code is identical but moving it seemed to solve a caching issue with Hydra::PermissionsCache,
  # causing a user to not have permission to view their newly created work,
  # and requiring a restart of the rails server to reset it.
  # May need to override in catalog_controller as well, but only doing it here for now.
  def enforce_show_permissions(opts={})
    permissions = current_ability.permissions_doc(params[:id])
    if permissions.under_embargo? && !can?(:edit, permissions)
      raise Hydra::AccessDenied.new("This item is under embargo.  You do not have sufficient access privileges to read this document.", :edit, params[:id])
    end
    unless can? :read, curation_concern
      raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which has been marked private.", :read, params[:id])
    end
  end

  def show
    respond_to do |format|
      format.html
      format.jsonld { render json: curation_concern.as_jsonld }
    end
  end

  def show_stub_information
    respond_to do |format|
      format.html
      format.jsonld { render json: curation_concern.as_jsonld.slice('@contect', '@id', 'nd:afmodel') }
    end
  end
end
