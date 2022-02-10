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
    request_subject = "[#{ curation_concern.human_readable_type } Access Request] for #{curation_concern.title} (id: #{curation_concern.noid})"
    request_body = "I am interested in #{ curation_concern.title }.\nI would like to view one of the withheld files associated with it (id: #{file.noid})."
    request_html = <<-markup
      request permission to view this file from #{this_request["access_request_department"]}.
      <p>
      <a class="btn btn-default" href="mailto:#{URI.escape(this_request["access_request_recipient"])}?subject=#{URI.escape(request_subject)}&body=#{URI.escape(request_body)}">Request Access</a>
      </p>
    markup
  end

  def access_request_allowed?
    return false if this_request.nil?
    return false if request_recipient.nil?
    return true
  end

  # Validate request renewal after access denied
  def access_renewal_request_allowed?(token_sha)
    TemporaryAccessToken.access_request_allowed_for?(token_sha)
  end

  # Prepare error info for access denied w/ token
  def build_access_renewal_request(token_sha)
    TemporaryAccessToken.build_renewal_request_for(token_sha)
  end

  def not_curate_minted_doi?(doi)
    # Is this the best way to identify a curate-minted doi?
    return false if doi.include?(Figaro.env.doi_shoulder)
    true
  end

  private

  def request_recipient
    return this_request["access_request_recipient"] if this_request["access_request_method"] == "email"
    # return some metadata field if this_request["access_request_method"] == "metadata"
    nil
  end

  def this_request
    @this_request ||= access_request_data[curation_concern.class.to_s.downcase]
  end

  def access_request_data
    TemporaryAccessToken.access_request_data
  end
end
