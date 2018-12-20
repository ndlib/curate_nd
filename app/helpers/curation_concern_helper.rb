module CurationConcernHelper
  def curation_concern_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: CurationConcernFormBuilder)), &block)
  end

  def decode_administrative_unit(curation_concern, method_name, label = nil, options = { class: 'descriptive-text' }, decorator: Catalog::HierarchicalValuePresenter)
    return unless curation_concern.respond_to?(:administrative_unit)
    markup = ""
    label ||= derived_label_for(curation_concern, method_name)
    administrative_unit = curation_concern.public_send(method_name)
    return markup if administrative_unit.blank?
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    [administrative_unit].flatten.compact.each do |hierarchy|
      markup << safe_join(decorator.send(:call, value: hierarchy, opener: '<li class="attribute">', closer: '</li>', link: true))
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

  def build_access_request_for(curation_concern, file)
    # look first for class-specific information
    this_request = access_request_data[curation_concern.class.to_s.downcase]
    # if not found, get default
    this_request ||= access_request_data['default']

    request_subject = "[#{ curation_concern.human_readable_type } Access Request] for #{curation_concern.title} (id: #{curation_concern.noid})"
    request_body = "I am interested in #{ curation_concern.title }.\nI would like to view one of the withheld files associated with it (id: #{file.noid})."
    request_html = <<-markup
      request permission to view this file from the #{this_request["access_request_department"]}.
      <p>
      <a class="btn btn-default" href="mailto:#{URI.escape(this_request["access_request_recipient"])}?subject=#{URI.escape(request_subject)}&body=#{URI.escape(request_body)}">Request Access</a>
      </p>
    markup
  end

  def access_request_data
    @access_request_data ||= YAML.load( File.open( Rails.root.join( 'config/access_request_map.yml' ) ) ).freeze
  end
end
