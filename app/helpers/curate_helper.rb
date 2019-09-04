module CurateHelper
  def support_email_link(options = {})
    mail_to(t('sufia.help_email'), t('sufia.help_email'), { subject: t('sufia.help_email_subject') }.merge(options)).html_safe
  end

  # Loads the object and returns its title
  def collection_title_from_pid(value)
    begin
      c = Collection.load_instance_from_solr(value)
    rescue => e
      logger.warn("WARN: Helper method collection_title_from_pid raised an error when loading #{value}.  Error was #{e}")
    end
    c.nil? ? value : c.title
  end

  # Gets the user friendly group title by id. Note: This implementation does not support multiples,
  # ex: "und:groupid1 OR und:groupid2"
  def group_name_from_pid(value)
    begin
      group = Hydramata::Group.load_instance_from_solr(value)
    rescue => e
      logger.debug("DEBUG: Helper method group_name_from_pid raised an error when loading #{value}.  Error was #{e}")
    end
    group.nil? ? value : group.title
  end

  def construct_page_title(*elements)
    (elements.flatten.compact + [application_name]).join(' // ')
  end

  def curation_concern_page_title(curation_concern)
    if curation_concern.persisted?
      construct_page_title(curation_concern.title, "#{curation_concern.human_readable_type} [#{curation_concern.to_param}]")
    else
      construct_page_title("New #{curation_concern.human_readable_type}")
    end
  end

  def default_page_title
    text = controller_name.singularize.titleize
    text = "#{action_name.titleize} " + text if action_name
    construct_page_title(text)
  end

  # Responsible for rendering, in a consistent manner.
  #
  # @param curation_concern
  # @param method_name [Symbol]
  # @param label [String] optional
  # @param options [Hash]
  # @option include_empty [Boolean] (false)
  # @option block_formatting [Boolean] (false)
  # @option callout_text [String, nil] (nil)
  # @option callout_pattern [Regexp, nil] (nil)
  # @option template [String] (table) table or dl
  def curation_concern_attribute_to_html(curation_concern, method_name, label = nil, options = {})
    subject = curation_concern.public_send(method_name)
    return '' if !subject.present? && !options[:include_empty]
    label ||= derived_label_for(curation_concern, method_name)
    render_collection_as_tabular_list(subject, method_name, label, options)
  end

  def thumbnail_display_for_document(curation_concern, title_link, _options = {})
    markup = ''
    markup << %(<a href=\"#{title_link}\">)
    begin
      file = ActiveFedora::Base.load_instance_from_solr(curation_concern.representative)
      markup << %( <img class="canonical-image" src=\"#{download_path(curation_concern.representative,  'thumbnail')}\" alt="Thumbnail">)
    rescue ActiveFedora::ObjectNotFoundError => e
      exception = Curate::Exceptions::RepresentativeObjectMissingError.new(e, curation_concern)
      Raven.capture_exception(exception, extra: { curation_concern: curation_concern.pid } )
      markup << image_tag('curate/default.png', class: "canonical-image")
    end
    markup << %(</a>)
    markup.html_safe
  end

  def rescue_from_representative_missing(curation_concern, attributes_html, exception)
    logger.error("Could not find representative pid for work: #{curation_concern.pid.inspect}")
    Raven.capture_exception(exception, extra: { curation_concern: curation_concern.pid } )
    markup = ''
    markup << %(<div class="row">)
    markup << %( <div class="work-representation span3">)
    markup << image_tag('curate/default.png', class: "canonical-image")
    markup << %(  </div>)
    markup << %(<div class="work-attributes span9">)
    markup << attributes_html
    markup << %(</div>)
    markup << %(</div>)
    markup << %(</div>)
    markup.html_safe
  end

  # Responsible for rendering the tabular list in a consistent manner.
  #
  # Note: There are switches based on the method_name provided
  def render_collection_as_tabular_list(collection, method_name, label, options = {})
    block_formatting = options.fetch(:block_formatting, false)
    template_type = options.fetch(:template, 'table')
    template = begin
      if template_type == 'dl'
        { tag: 'dd', opener: %(<dt>#{label}</dt>), closer: '' }
      else
        { tag: 'li', opener: %(<tr><th>#{label}</th>\n<td><ul class="tabular">), closer: '</ul></td></tr>' }
      end
    end
    markup = ''

    markup << template.fetch(:opener)
    tag = template.fetch(:tag)
    [collection].flatten.compact.each do |value|
      if respond_to?("__render_tabular_list_item_for_#{method_name}", true) # Need to check for private methods
        markup << send("__render_tabular_list_item_for_#{method_name}", method_name, value, block_formatting, tag, options)
      else
        markup << __render_tabular_list_item(method_name, value, block_formatting, tag, options)
      end
    end
    markup << template.fetch(:closer)
    markup.html_safe
  end
  private :render_collection_as_tabular_list

  def __render_tabular_list_item(method_name, value, block_formatting, tag, _options = {})
    inner_html = block_given? ? yield : h(richly_formatted_text(value, block: block_formatting))
    %(<#{tag} class="attribute #{method_name}">#{inner_html}</#{tag}>\n)
  end
  private :__render_tabular_list_item

  def __render_tabular_list_item_for_rights(method_name, value, block_formatting, tag, options = {})
    # Special treatment for license/rights.  A URL from the Sufia gem's config/sufia.rb is stored in the descMetadata of the
    # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
    parsedUri = begin
                  URI.parse(value)
                rescue
                  nil
                end
    if parsedUri.nil?
      __render_tabular_list_item(method_name, value, block_formatting, tag, options)
    else
      __render_tabular_list_item(method_name, value, block_formatting, tag, options) do
        %(<a href=#{h(value)} target="_blank"> #{h(Copyright.label_from_uri(value))}</a>)
      end
    end
  end
  private :__render_tabular_list_item_for_rights

  def __render_tabular_list_item_for_relation(method_name, value, block_formatting, tag, options = {})
    callout_pattern = options.fetch(:callout_pattern, nil)
    if callout_pattern
      callout_text = options.fetch(:callout_text)
      if value =~ callout_pattern
        __render_tabular_list_item(method_name, value, block_formatting, tag, options) do
          %(<a href="#{h(value)}" class="callout-link" target="_blank"><span class="callout-text">#{callout_text}</span></a>)
        end
      else
        __render_tabular_list_item(method_name, value, block_formatting, tag, options)
      end
    else
      __render_tabular_list_item(method_name, value, block_formatting, tag, options)
    end
  end
  private :__render_tabular_list_item_for_relation

  alias __render_tabular_list_item_for_tag __render_tabular_list_item_for_relation
  private :__render_tabular_list_item_for_tag

  def __render_tabular_list_item_for_source(method_name, value, block_formatting, tag, options = {})
    SourceCalloutAttributeRenderer.render(view_context: self, method_name: method_name, value: value, block_formatting: block_formatting, tag: tag, options: options)
  end
  private :__render_tabular_list_item_for_source

  def __render_tabular_list_item_for_alephIdentifier(method_name, value, block_formatting, tag, options = {})
    callout_text = 'View the library catalog record for this item'
    __render_tabular_list_item(method_name, value, block_formatting, tag, options) do
      %(<a href="http://onesearch.library.nd.edu/NDU:nd_campus:ndu_aleph#{h(value)}" target="_blank"><span class="callout-text">#{callout_text} (#{value})</span></a>)
    end
  end
  private :__render_tabular_list_item_for_alephIdentifier

  def __render_tabular_list_item_for_library_collections(method_name, value, block_formatting, tag, options)
    __render_tabular_list_item(method_name, value, block_formatting, tag, options) do
      %(<a href="/show/#{value.noid}">#{h(value.title)}</a>)
    end
  end

  # options[:block_formatting, :class]
  def curation_concern_attribute_to_formatted_text(curation_concern, method_name, label = nil, options = {})
    markup = ''
    label ||= derived_label_for(curation_concern, method_name)
    subject = curation_concern.public_send(method_name)
    options.reverse_merge!(block_formatting: true, class: 'descriptive-text')
    return markup if subject.blank?
    markup << %(<h2 class="#{method_name}-label">#{label}</h2>\n<section class="#{method_name}-list">\n)
    [subject].flatten.compact.each do |value|
      markup << %(<article class="#{method_name} #{options[:class]}">\n#{richly_formatted_text(value, block: options[:block_formatting])}\n</article>\n)
    end
    markup << %(</section>)
    markup.html_safe
  end

  def derived_label_for(curation_concern, method_name)
    curation_concern.respond_to?(:label_for) ? curation_concern.label_for(method_name) : method_name.to_s.humanize.titlecase
  end
  private :derived_label_for

  def classify_for_display(curation_concern)
    curation_concern.human_readable_type.downcase
  end

  def link_to_edit_permissions(curation_concern, solr_document = nil)
    markup = <<-HTML
      <a href="#{edit_polymorphic_path_for_asset(curation_concern)}" id="permission_#{curation_concern.to_param}">
        #{permission_badge_for(curation_concern, solr_document)}
      </a>
    HTML
    markup.html_safe
  end

  def permission_badge_for(curation_concern, solr_document = nil)
    solr_document ||= curation_concern.to_solr
    dom_label_class, link_title = extract_dom_label_class_and_link_title(solr_document)
    %(<span class="label #{dom_label_class}" title="#{link_title}">#{link_title}</span>).html_safe
  end

  def polymorphic_path_args(asset)
    # A better approximation, but we still need one location for this information
    # either via routes or via the initializer of the application
    if asset.class.included_modules.include?(CurationConcern::Model)
      return [:curation_concern, asset]
    else
      return asset
    end
  end

  def polymorphic_path_for_asset(asset)
    polymorphic_path(polymorphic_path_args(asset))
  end

  def edit_polymorphic_path_for_asset(asset)
    edit_polymorphic_path(polymorphic_path_args(asset))
  end

  # This converts a collection of objects to a 2 dimensional array having keys accessed via the key_method on the objects
  # and the values accessed via the value_method on the objects.
  # key_method and value_method are strings which are the names of the methods or accessors or attributes by
  # which the value of the key and the value of the array value can be acquired for each of the objects.  These
  # values for the key and the value are placed into the returned array.
  # EXAMPLE:  Oh is class which has methods a, b, c, d, e on it (Oh.a, Oh.b, etc.).  You want an array of
  #           a collection of Ohs.  The array would contain the value of b as the key and the value of e as the corresponding value.
  #           The collection of Ohs is in the variable ohList.
  #           ohArray = objects_to_array(ohList, 'b', 'e')
  def objects_to_array(collection, key_method, value_method)
    returnArray = collection.map do |element|
      [get_value_for(element, key_method), get_value_for(element, value_method)]
    end
  end

  # This is a private helper method which given an item (an object), retrieves the value of some member on it by way of
  # what is specified in the by_means_of parameter.  by_means_of is the string name of a method, an accessor, an
  # attribute, or other mechanism which can access that information on the item.
  def get_value_for(item, by_means_of)
    by_means_of.respond_to?(:call) ? by_means_of.call(item) : item.send(by_means_of)
  end
  private :get_value_for

  def extract_dom_label_class_and_link_title(document)
    hash = document.stringify_keys
    dom_label_class = 'label-important'
    link_title = 'Private'
    if hash[Hydra.config[:permissions][:read][:group]].present?
      if hash[Hydra.config[:permissions][:read][:group]].include?('public')
        if hash[Hydra.config[:permissions][:embargo_release_date]].present?
          dom_label_class = 'label-warning'
          link_title = 'Embargo then Public'
        else
          dom_label_class = 'label-success'
          link_title = 'Public'
        end
      elsif hash[Hydra.config[:permissions][:read][:group]].include?('registered')
        dom_label_class = 'label-info'
        link_title = t('sufia.institution_name')
      end
    end
    [dom_label_class, link_title]
  end
  private :extract_dom_label_class_and_link_title

  def auto_link_without_protocols(url)
    link = (url =~ /\A(?i)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/) ? 'http://' + url : url
    auto_link(link, :all)
  end

  def richly_formatted_text(text, options = {})
    return if text.blank?
    options.reverse_merge!(block: false, title: false)
    markup = Curate::TextFormatter.call(text: text.to_s, block: options[:block], title: options[:title])
    markup.html_safe unless markup.nil?
  end

  def escape_html_for_solr_text(text)
    return if text.nil?
    modified_text = CGI.escapeHTML(text)
    richly_formatted_text(CGI.unescapeHTML(CGI.unescapeHTML(modified_text)))
  end

  # The "search inside" URL needs an inclusive hierarchy of collection titles and pids.
  # The full hierarchy is is not stored on the Collection object itself; it is only
  # available on child objects. However, the full path can be constructed using
  # metadata from colection itself and information from its Solr Doc. This
  # method duplicates parts of Curate::LibraryCollectionIndexingAdapter
  def search_collection_pathbuilder(curation_concern)
    hierarchy_root_field = Curate::LibraryCollectionIndexingAdapter::SOLR_KEY_PATHNAME_HIERARCHY_WITH_TITLES
    solr_query_string = ActiveFedora::SolrService.construct_query_for_pids([curation_concern.pid])
    solr_results = ActiveFedora::SolrService.query(solr_query_string)
    return false unless solr_results && solr_results.first
    solr_doc = solr_results.first
    collection_key_root = solr_doc.fetch(hierarchy_root_field, []).first
    collection_key = ''
    collection_key << "#{collection_key_root}/" if collection_key_root.present?
    collection_key << "#{curation_concern.title}|#{curation_concern.pid}"
    return false unless collection_key.present?
    catalog_index_path(f: { ::Catalog::SearchSplashPresenter.collection_key => [collection_key] })
  end

  # until such a time that the manifest is stored in the item itself, we need to construct it
  def manifest_url_for(id:)
    Rails.configuration.manifest_url_generator.call(id: id)
  end
end
