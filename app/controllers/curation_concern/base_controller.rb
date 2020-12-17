module CurationConcern
  class BaseController < ApplicationController
    include Morphine
    before_filter :attach_action_breadcrumb
    def attach_action_breadcrumb
      case action_name
      when 'show'
        add_breadcrumb curation_concern.human_readable_type, request.path
      when 'new', 'create'
        add_breadcrumb "New #{curation_concern.human_readable_type}", request.path
      else
        add_breadcrumb curation_concern.human_readable_type, common_object_path(curation_concern)
        add_breadcrumb action_name.titleize, request.path
      end
    end
    protected :attach_action_breadcrumb

    with_themed_layout
    include Sufia::Noid # for normalize_identifier method
    include Curate::FieldsForAddToCollection

    before_filter :authenticate_user!, :except => [:show]
    before_filter :agreed_to_terms_of_service!, :except => [:show]
    before_filter :force_update_user_profile! , :except => [:show]
    prepend_before_filter :normalize_identifier, except: [:index, :new, :create]
    before_filter :curation_concern, except: [:index]

    class_attribute :excluded_actions_for_curation_concern_authorization
    self.excluded_actions_for_curation_concern_authorization = [:new, :create]
    before_filter :authorize_curation_concern!, except: excluded_actions_for_curation_concern_authorization
    def authorize_curation_concern!
      if action_name_for_authorization == :show
        if can?(:show, curation_concern)
          return true
        else
          render 'unauthorized', status: :unauthorized
          false
        end
      else
        if is_orphan_file? && cannot_view_orphans?
          render show_tombstone_page, status: 410
        else
          authorize!(action_name_for_authorization, curation_concern) || true
        end
      end
    end

    def action_name_for_authorization
      action_name.to_sym
    end
    protected :action_name_for_authorization

    helper_method :curation_concern

    def contributor_agreement
      @contributor_agreement ||= ContributorAgreement.new(curation_concern, current_user, params)
    end

    helper_method :contributor_agreement

    def cloud_resources_to_ingest
      @cloud_resources_to_ingest ||= CloudResource.new(curation_concern, current_user, params).resources_to_ingest
    end

    helper_method :cloud_resources_to_ingest

    class_attribute :curation_concern_type
    self.curation_concern_type = GenericWork

    def attributes_for_actor
      return params[hash_key_for_curation_concern] if cloud_resources_to_ingest.nil?
      params[hash_key_for_curation_concern].merge!(:cloud_resources=>cloud_resources_to_ingest)
    end

    def hash_key_for_curation_concern
      curation_concern_type.name.underscore.to_sym
    end

    def affiliations
      @affiliations ||= Affiliation.values.collect{|entity|[entity.label,entity.human_name]}
    end
    helper_method :affiliations

    register :curation_concern do
      if params[:id]
        if curation_concern_type == ActiveFedora::Base
          curation_concern_type.find(params[:id], cast: true)
        else
          curation_concern_type.find(params[:id])
        end
      else
        curation_concern_type.new
      end
    end

    def cannot_view_orphans?
      return false if RepoManager.with_active_privileges?(current_user)
      true
    end

    def is_orphan_file?
      return true if curation_concern.is_a?(GenericFile) && curation_concern.parent.nil?
      false
    end

    def show_tombstone_page
      'curation_concern/base/tombstone'
    end

  end
end
