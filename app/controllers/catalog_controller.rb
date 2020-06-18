# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'csv'

# @note This code is a copy of a module from cbeer's (BlacklightFacetExtras gem)[github.com/cbeer/blacklight_facet_extras]
# I have chosen to paste this directly into the catalog controller to show that
# there are significant changes to the catalog controller behavior.
#
# Meant to be applied on top of a controller that implements
# Blacklight::SolrHelper. Will inject tag limiting behaviors
# to solr parameters creation.
module BlacklightFacetExtras
  module Multiple
    module ControllerExtension
      def self.included(some_class)
        some_class.solr_search_params_logic << :add_inclusive_facets_to_solr unless some_class.solr_search_params_logic.include? :add_inclusive_facets_to_solr
        some_class.solr_search_params_logic << :add_multiple_facets_to_solr unless some_class.solr_search_params_logic.include? :add_multiple_facets_to_solr
        some_class.solr_search_params_logic << :add_exclude_person_to_solr
        some_class.helper BlacklightFacetExtras::Multiple::ViewHelperExtension
      end

      def add_exclude_person_to_solr(solr_parameters, user_params)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "-active_fedora_model_ssi:Person"
      end

      ##
      # Add any existing facet limits, stored in app-level HTTP query
      # as :f, to solr as appropriate :fq query.
      def add_inclusive_facets_to_solr(solr_parameters, user_params)
        # :fq, map from :f_inclusive.
        if ( user_params[:f_inclusive])
          f_request_params = user_params[:f_inclusive]
          solr_parameters[:fq] ||= []
          f_request_params.each_pair do |facet_field, value_list|
            value_list ||= []
            value_list = [value_list] unless value_list.respond_to? :each
            user_params[:f] ||= {}
            solr_parameters[:fq] << "{!tag=#{facet_field.parameterize}}#{value_list.map { |value| "_query_:\"#{facet_value_to_fq_string(facet_field, value).gsub('"', '\\"')}\"" }.join(" OR ")}"
          end
        end
      end

      def add_multiple_facets_to_solr(solr_parameters, user_parameters)
        return unless solr_parameters[:"facet.field"]

        solr_parameters[:"facet.field"].each_with_index.select { |field, index| blacklight_config.facet_fields[field].try(:multiple) }.each do |field, index|
          solr_parameters[:"facet.field"][index] = "{!ex=#{field.parameterize}}#{field}"
        end
      end
    end

    module ViewHelperExtension
      # adds the value and/or field to params[:f_inclusive]
      # Does NOT remove request keys and otherwise ensure that the hash
      # is suitable for a redirect. See
      # add_facet_params_and_redirect
      # def add_facet_params(field, value, source_params = params)
      #   if blacklight_config.facet_fields[field] && blacklight_config.facet_fields[field].multiple
      #     p = params.dup
      #     p[:f_inclusive] = (p[:f_inclusive] || {}).dup # the command above is not deep in rails3, !@#$!@#$
      #     p[:f_inclusive][field] = (p[:f_inclusive][field] || []).dup
      #     p[:f_inclusive][field].push(value)
      #     p
      #   else
      #     super
      #   end
      # end

      # Renders the "My X" and "All X" links in the Views sidebar
      def render_view_filters(user_params = params)
        mine_selected = (user_params["works"] == 'mine')

        localized_params = user_params.deep_dup
        localized_params["works"] = "mine"
        my_works_class = (mine_selected ? "active-item" : "inactive-item")
        my_works = content_tag :li, { class: my_works_class } do
          link_to url_for(localized_params) do
            content_tag :span, "My #{catalog_type}"
          end
        end

        localized_params["f"].select! { |f| f != "edit_access_group_ssim" } if localized_params.include?("f")
        localized_params["works"] = "all"
        all_works_class = (!mine_selected ? "active-item" : "inactive-item")
        all_works = content_tag :li, { class: all_works_class } do
          link_to url_for(localized_params) do
            content_tag :span, "All #{catalog_type}"
          end
        end

        content = []
        content << all_works
        content << my_works
        content.join("\n").html_safe
      end

      def render_constraints_filters(localized_params = params)
        return "".html_safe if localized_params[:f].blank? && localized_params[:f_inclusive].blank?
        content = []
        if localized_params[:f]
          localized_params[:f].each_pair do |facet,values|
            content << render_filter_element(facet, Array.wrap(values), localized_params)
          end
        end
        if localized_params[:f_inclusive]
          localized_params[:f_inclusive].each_pair do |facet,values|
            content << render_filter_element(facet, [Array.wrap(values).join(" OR ")], localized_params)
          end
        end
        return content.flatten.join("\n").html_safe
      end

      # copies the current params (or whatever is passed in as the 3rd arg)
      # removes the field value from params[:f]
      # removes the field if there are no more values in params[:f][field]
      # removes additional params (page, id, etc..)
      def remove_facet_params(field, value, source_params=params)
        if blacklight_config.facet_fields[field] && blacklight_config.facet_fields[field].multiple
          p = super
          # need to dup the facet values too,
          # if the values aren't dup'd, then the values
          # from the session will get remove in the show view...
          p[:f_inclusive] = (p[:f_inclusive] || {}).dup
          p[:f_inclusive].delete(field) if p[:f_inclusive].key?(field)
          p.delete(:f_inclusive) if p[:f_inclusive].empty?
          p
        else
          p = super
          p.delete(:f) if p[:f].empty? unless p[:f].nil?
          p
        end
      end

      # true or false, depending on whether the field and value is in params[:f]
      def facet_in_params?(field, value)
        super || (params[:f_inclusive] and params[:f_inclusive][field] and params[:f_inclusive][field].include?(value))
      end

      # Standard display of a SELECTED facet value, no link, special span
      # with class, and 'remove' button.
      def render_selected_facet_value(facet_solr_field, item)
        #Updated class for Bootstrap Blacklight
        content_tag(:span, render_facet_value(facet_solr_field, item, :suppress_link => true), :class => "selected") +
          link_to(content_tag(:i, '', :class => "icon-remove") + content_tag(:span, '[remove]', :class => 'hide-text'), remove_facet_params(facet_solr_field, item, params), :class=>"remove")
      end

      def render_facet_limit(display_facet, options = {})
        if display_facet.is_a? String or display_facet.is_a? Symbol
          $stderr.puts "DEPRECATION WARNING: Blacklight::FacetsHelper#render_facet_limit: use #render_facet_partials to render facets by field name"
          return render_facet_partials([display_facet])
        end
        return if not should_render_facet?(display_facet)
        config = facet_configuration_for_field(display_facet.name)
        options = options.dup
        options[:partial] ||= facet_partial_name(display_facet)
        options[:layout] ||= config.try(:layout) || "facet_layout" unless options.has_key?(:layout)
        options[:locals] ||= {}
        options[:locals][:solr_field] ||= display_facet.name
        options[:locals][:solr_fname] ||= display_facet.name # DEPRECATED
        options[:locals][:facet_field] ||= facet_configuration_for_field(display_facet.name)
        options[:locals][:display_facet] ||= display_facet
        render(options)
      end
    end
  end
end

class CatalogController < ApplicationController
    # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BreadcrumbsOnRails::ActionController
  include Curate::ThemedLayoutController
  include Curate::FieldsForAddToCollection
  include Hydramata::SolrHelper
  include Blacklight::Catalog
  # Order matters for this; It should be after the various blacklight and solr modules
  include BlacklightFacetExtras::Multiple::ControllerExtension

  layout 'curate_nd_catalog'

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show
  CatalogController.solr_search_params_logic += [:remove_group_facets]
  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # Enforce embargo on all Solr queries
  CatalogController.solr_search_params_logic += [:enforce_embargo]
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic += [:exclude_unwanted_models]
  CatalogController.solr_search_params_logic += [:show_only_works]

  skip_before_filter :default_html_head


  # get search results from the solr index
  def index
    collection_options
    (@response, @document_list) = get_search_results
    @filters = params[:f] || []

    respond_to do |format|
      format.html {
        # extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => t('blacklight.search.rss_feed') )
        # extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => t('blacklight.search.atom_feed') )
      }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json { render json: render_search_results_as_json }
      format.jsonld { render text: CatalogIndexJsonldPresenter.new(@response, request.url, request.query_parameters).to_jsonld, layout: false }
      format.csv { send_data ExportCsvPresenter.new(@response).to_csv, layout: false, filename: "search-results-#{Time.now}.csv" }
    end
  end

  def hierarchy_facet
    @pagination = get_facet_pagination(params[:id], params)
    (@response, @document_list) = get_search_results
    respond_to do |format|
      # Draw the facet selector for users who have javascript disabled:
      format.html { render layout: 'curate_nd/1_column'}
      format.json { render json: render_facet_list_as_json }

      # Draw the partial for the "more" facet modal window:
      format.js { render :layout => false }
    end
  end

  def departments
    # Oh Blacklight and your pervasive assumptions about rendering and response objects.
    # params[:id] should == 'admin_unit_hierarchy_sim'
    @pagination = get_facet_pagination(params[:id], params)
    (@response, @document_list) = get_search_results
    respond_to do |format|
      # Instead of relying on the Blacklight hierarchy rendering, I want to
      # leverage the Locabulary hiararchy sorter.
      format.html do
        @departments = build_faceted_hierarchy_presenter(@response, 'administrative_units')
        render layout: 'curate_nd/1_column'
      end
      format.json { render json: render_facet_list_as_json }

      # Draw the partial for the "more" facet modal window:
      # Instead of relying on the Blacklight hierarchy rendering, I want to
      # leverage the Locabulary hiararchy sorter.
      format.js do
        @departments = build_faceted_hierarchy_presenter(@response, 'administrative_units')
        render layout: false
      end
    end
  end

  # Group facet is added by default to preserve it's order in the list, but we only want to
  # show it when the user is viewing "My Works". This removes the facet when not viewing "My Works".
  # If there is a way to dynamically add it to the config based on a user param and specify the order,
  # then we can invert this logic to add instead of remove
  def remove_group_facets(solr_parameters, user_params)
    only_mine = (user_params["works"] == 'mine')
    if !only_mine
      user_params["f"].delete "edit_access_group_ssim" if user_params["f"] && user_params["f"].include?("edit_access_group_ssim")
      blacklight_config.facet_fields.delete "edit_access_group_ssim" if blacklight_config.facet_fields && blacklight_config.facet_fields.include?("edit_access_group_ssim")
    end
  end

  def build_faceted_hierarchy_presenter(solr_response, predicate_name)
    FacetedHierarchyPresenter.new(
      facet_field_name: params[:id],
      items: solr_response.facet_by_field_name(params[:id]).items,
      item_delimiter: ':',
      predicate_name: predicate_name
    )
  end

  def self.uploaded_field
    #  system_create_dtsi
    solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('desc_metadata__date_modified', :stored_sortable , type: :date)
  end

  def self.created_field
    solr_name('date_created_derived', :stored_sortable, type: :date)
  end

  def self.search_config
     # Set parameters to send to SOLR
     # First inspect contents of the hash from Yaml configuration file
     # See config/search_config.yml
     initialized_config = Curate.configuration.search_config['catalog']
     # If the hash is empty, set reasonable defaults for this search type
     if initialized_config.nil?
        Hash['qf' => ['desc_metadata__title_tesim','desc_metadata__name_tesim'],'qt' => 'search','rows' => 12]
     else
        initialized_config
     end
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qf: search_config['qf'],
      qt: search_config['qt'],
      rows: search_config['rows']
    }

    # solr field configuration for search results/index views
    config.index.show_link = solr_name("desc_metadata__title", :stored_searchable)
    config.index.record_display_type = "id"

    # solr field configuration for document/show views
    config.show.html_title = solr_name("desc_metadata__title", :stored_searchable)
    config.show.heading = solr_name("desc_metadata__title", :stored_searchable)
    config.show.display_type = solr_name("has_model", :symbol)

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field "edit_access_group_ssim", label: "My Groups", limit: 5, multiple: false, helper_method: :group_name_from_pid
    config.add_facet_field(
      solr_name('admin_unit_hierarchy', :facetable),
      label: 'Department or Unit',
      layout: 'catalog/hierarchy_facet_layout',
      partial: 'catalog/hierarchy_facet',
      limit: 9999,
      sort: 'count'
    )
    config.add_facet_field(
      Curate::LibraryCollectionIndexingAdapter::SOLR_KEY_PATHNAME_HIERARCHY_WITH_TITLES_FACETABLE,
      label: 'Collection',
      layout: 'catalog/hierarchy_facet_layout',
      limit: 9999,
      partial: 'catalog/hierarchy_facet',
      sort: 'count'
    )
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type of Work", limit: 5, multiple: true
    config.add_facet_field solr_name(:desc_metadata__creator, :facetable), label: "Creator", limit: 5
    config.add_facet_field solr_name("desc_metadata__tag", :facetable), label: "Related Resource(s)", limit: 5
    config.add_facet_field solr_name("desc_metadata__subject", :facetable), label: "Subject", limit: 5
    config.add_facet_field solr_name("desc_metadata__language", :facetable), label: "Language", limit: 5
    config.add_facet_field solr_name("desc_metadata__based_near", :facetable), label: "Location", limit: 5
    config.add_facet_field solr_name("desc_metadata__publisher", :facetable), label: "Publisher", limit: 5
    config.add_facet_field solr_name("desc_metadata__affiliation", :facetable), label: "Academic Status", limit: 5
    config.add_facet_field solr_name("file_format", :facetable), label: "File Format", limit: 5
    config.facet_display = {
      :hierarchy => {
        'admin_unit_hierarchy' => {
          fields: ['sim']
        },
        'library_collections_pathnames_hierarchy_with_titles' => {
          fields: ['sim'],
          delimiter: '/',
          presenter: Catalog::HierarchicalTermLabel::TitleExtractor
        }
      }
    }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_index_field solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_index_field solr_name("desc_metadata__relation", :facetable, type: :string), label: "Related Source(s)"
    config.add_index_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_index_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_index_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_index_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_index_field solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_index_field solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_index_field solr_name("desc_metadata__date_uploaded", :stored_sortable, type: :string), label: "Date Uploaded"
    config.add_index_field solr_name("desc_metadata__date_modified", :stored_sortable, type: :string), label: "Date Modified"
    config.add_index_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_index_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_index_field solr_name("human_readable_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_index_field solr_name("desc_metadata__format", :stored_searchable, type: :string), label: "File Format"
    config.add_index_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_show_field solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_show_field solr_name("desc_metadata__relation", :stored_searchable, type: :string), label: "Keyword"
    config.add_show_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_show_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_show_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_show_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_show_field solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_show_field solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_show_field solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), label: "Date Uploaded"
    config.add_show_field solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), label: "Date Modified"
    config.add_show_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_show_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_show_field solr_name("human_readable_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_show_field solr_name("desc_metadata__format", :stored_searchable, type: :string), label: "File Format"
    config.add_show_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields', :include_in_advanced_search => false) do |field|
      title_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
      label_name = solr_name("desc_metadata__name", :stored_searchable, type: :string)
      contributor_name = solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
      description_name = solr_name("desc_metadata__description", :stored_searchable, type: :string)
      abstract_name = solr_name("desc_metadata__abstract", :stored_searchable, type: :string)
      creator_name = solr_name("desc_metadata__creator", :stored_searchable)
      publisher_name = solr_name("desc_metadata__publisher", :stored_searchable, type: :string)
      language_name = solr_name("desc_metadata__language", :stored_searchable, type: :string)
      collection_name = solr_name("desc_metadata__collection_name", :stored_searchable, type: :string)
      contributor_institution_name = solr_name("desc_metadata__contributor_institution", :stored_searchable, type: :string)
      subject_name = solr_name("desc_metadata__subject", :stored_searchable, type: :string)
      author_name = solr_name("desc_metadata__author", :stored_searchable, type: :string)
      identifier_name = solr_name("desc_metadata__identifier", :facetable, type: :string)
      urn  = solr_name("desc_metadata__urn", :stored_searchable, type: :string)
      degree_name  = solr_name("degree_name", :stored_searchable, type: :string)
      degree_disciplines = solr_name("degree_disciplines", :stored_searchable, type: :string)
      contributors = solr_name("contributors", :stored_searchable, type: :string)
      degree_department_acronyms = solr_name("degree_department_acronyms", :stored_searchable, type: :string)
      date_created = solr_name("desc_metadata__date_created", :stored_searchable, type: :string)
      source = solr_name("desc_metadata__source", :stored_searchable, type: :string)
      administrative_unit = "admin_unit_tesim"
      aleph_identifier = solr_name("desc_metadata__alephIdentifier", :stored_searchable, type: :string)
      patent_number = "desc_metadata__patent_number_tesim"
      field.solr_parameters = {
        :qf => "#{title_name} #{label_name} noid_tsi file_format_tesim #{contributor_name} #{abstract_name} #{description_name} #{creator_name} #{author_name} #{administrative_unit} #{publisher_name} #{language_name} #{collection_name} #{contributor_institution_name} #{subject_name} #{identifier_name} #{urn} #{degree_name} #{degree_disciplines} #{contributors} #{degree_department_acronyms} #{date_created} #{source} #{aleph_identifier} #{patent_number}",
        :pf => "#{title_name}"
      }
    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :"spellcheck.dictionary" => "contributor" }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end



    config.add_search_field('creator') do |field|
      field.solr_parameters = { :"spellcheck.dictionary" => "creator" }
      solr_name = solr_name("desc_metadata__creator", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "title"
      }
      solr_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Description or Summary"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "description"
      }
      solr_name = solr_name("desc_metadata__description", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('abstract') do |field|
      field.label = "Abstract or Summary"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "abstract"
      }
      solr_name = solr_name("desc_metadata__abstract", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "publisher"
      }
      solr_name = solr_name("desc_metadata__publisher", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "date_created"
      }
      solr_name = solr_name("desc_metadata__created", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "subject"
      }
      solr_name = solr_name("desc_metadata__subject", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('language') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "language"
      }
      solr_name = solr_name("desc_metadata__language", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('human_readable_type') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "human_readable_type"
      }
      solr_name = solr_name("human_readable_type", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('format') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "format"
      }
      solr_name = solr_name("desc_metadata__format", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "identifier"
      }
      solr_name = solr_name("desc_metadata__id", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "based_near"
      }
      solr_name = solr_name("desc_metadata__based_near", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('tag') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "tag"
      }
      solr_name = solr_name("desc_metadata__tag", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = solr_name("desc_metadata__depositor", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('rights') do |field|
      solr_name = solr_name("desc_metadata__rights", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end


    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "Sort by relevance"
    config.add_sort_field "#{created_field} desc", label: "Sort by newest date created"
    config.add_sort_field "#{created_field} asc", label: "Sort by oldest date created"
    config.add_sort_field "#{uploaded_field} desc", label: "Sort by newest upload"
    config.add_sort_field "#{uploaded_field} asc", label: "Sort by oldest upload"
    config.add_sort_field "#{modified_field} desc", label: "Sort by newest modification"
    config.add_sort_field "#{modified_field} asc", label: "Sort by oldest modification"


    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  protected

    # Override Hydra::PolicyAwareAccessControlsEnforcement
    def gated_discovery_filters
      if current_user and (current_user.manager? || current_user.can?(:read, :all))
        return []
      end
      super
    end

    # Overriding blacklight so that the search results can be displayed in a way compatible with
    # tokenInput javascript library.  This is used for suggesting "Related Works" to attach.
    def render_search_results_as_json
      {"docs" => @response["response"]["docs"].map {|solr_doc| serialize_work_from_solr(solr_doc) }}
    end

    def serialize_work_from_solr(solr_doc)
      title = solr_doc["desc_metadata__title_tesim"].first
      title << " (#{solr_doc["human_readable_type_tesim"].first})" if solr_doc["human_readable_type_tesim"].present?
      {
        pid: solr_doc["id"],
        title: title
      }
    end

    # show only files with edit permissions in lib/hydra/access_controls_enforcement.rb apply_gated_discovery
    def discovery_permissions
      return ["edit"] if params[:works] == 'mine'
      super
    end


    # Limits search results just to GenericFiles
    # @param solr_parameters the current solr parameters
    # @param user_parameters the current user-subitted parameters
    def exclude_unwanted_models(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      [GenericFile, Profile, ProfileSection, LinkedResource,
       Hydramata::Group].each do |klass|
        solr_parameters[:fq] << exclude_class_filter(klass)
      end
    end

    #Excludes collection and person only when trying to filter by work.
    # This is included as part of blacklight search solr params logic
    def show_only_works(solr_parameters, user_parameters)
      if params.has_key?(:f) and params[:f].to_a.flatten == ["generic_type_sim","Work"]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "-has_model_ssim:\"info:fedora/afmodel:Collection\""
        solr_parameters[:fq] << "-has_model_ssim:\"info:fedora/afmodel:Person\""
      end
    end

    def depositor
      #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
      Solrizer.solr_name('depositor', :stored_searchable, type: :string)
    end

    def sort_field
      "#{Solrizer.solr_name('system_create', :sortable)} desc"
    end

    def exclude_class_filter(klass)
      '-' + ActiveFedora::SolrService.construct_query_for_rel(has_model:
                                                        klass.to_class_uri)
    end

    # override Blacklight::Catalog to include f_inclusive
    def has_search_parameters?
      !params[:q].blank? || !params[:f].blank? || !params[:f_inclusive].blank?
    end
end
