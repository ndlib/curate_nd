# Responsible for generating the JSON document for the api show response
class Api::ShowItemPresenter
  include Sufia::Noid
  attr_reader :item, :request_url

  TERMS = ['http://purl.org/dc/terms/',
           'http://purl.org/ontology/bibo/',
           'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#',
           'http://www.ndltd.org/standards/metadata/etdms/1.1/',
           'http://nd.edu/image#',
           'https://library.nd.edu/ns/terms/',
           'http://purl.org/pav/',
           'http://xmlns.com/foaf/0.1/',
           'http://id.loc.gov/vocabulary/relators/',
           'http://purl.org/vra/'].freeze

  def initialize(item, request_url)
    @item = item
    @request_url = RDF::URI.new(request_url)
    build_json!
  end

  # @return [String] the JSON document
  def to_json
    JSON.dump(@json)
  end

  private

  def build_json!
    json = {
      'requestUrl' => request_url,
      'id' => item_id
    }
    json = json.merge(process_datastreams(item))
    json = json.merge(add_relationships_and_links)
    @json = json
  end

  def item_id
    @item_id ||= Sufia::Noid.noidify(@item.id)
  end

  def add_relationships_and_links
    relationship_data = {}
    if item.respond_to?('generic_files')
      relationship_data['containedFiles'] = add_item_files
    end
    relationship_data
  end

  def add_item_files
    file_data = []
    item.generic_files.each do |file|
      file_id = Sufia::Noid.noidify(file.id)
      file_content = {
        'id' => file_id,
        'fileUrl' => url_for(pid: file_id, url_type: :show),
        'downloadUrl' => url_for(pid: file_id, url_type: :download)
      }
      single_file = file_content.merge(process_datastreams(file))
      file_data << single_file
    end
    file_data
  end

  def process_datastreams(object)
    data = {}
    object.datastreams.each do |dsname, ds|
      next if dsname == 'DC'
      method_key = "process_#{dsname.gsub('-', '')}".to_sym
      if respond_to?(method_key, true)
        parsed_data = self.send(method_key, ds)
        data = merge_hashes(data, parsed_data)
      else
        Rails.logger.error("#{item_id}: unknown datastream #{dsname}")
      end
    end
    data
  end

  def process_descMetadata(ds)
    data = ds.datastream_content.force_encoding('utf-8')
    parse_triples(data)
  end

  def process_RELSEXT(ds)
    data = ds.datastream_content.force_encoding('utf-8')
    parse_rdfxml(data)
  end

  def process_rightsMetadata(ds)
    data = REXML::Document.new(ds.datastream_content)
    parse_xml(data)
  end

  def process_properties(ds)
    # return the parsed XML document
    data = REXML::Document.new(ds.datastream_content)
    parse_xml(data)
  end

  def process_characterization(ds)
    # return the characterization string without parsing
    data = {}
    return data unless ds.datastream_content.present?
    data['characterization'] = ds.datastream_content
    data
  end

  def process_bendoitem(ds)
    data = {}
    return data unless ds.datastream_content.present?
    data['bendoItem'] = ds.datastream_content
    data
  end

  def process_thumbnail(ds)
    data = {}
    # ds.datastream_content
    data['thumbnailUrl'] = url_for(pid: ds.pid, url_type: :thumbnail)
    data
  end

  def process_content(ds)
    data = {}
    data['downloadUrl'] = url_for(pid: ds.pid, url_type: :download)
    data['filename'] = ds.label
    data['mimeType'] = ds.mimeType
    bendo_url = bendo_location(ds.datastream_content)
    data['bendoUrl'] = bendo_url unless bendo_url.blank?
    data
  end

  def bendo_location(content)
    location = ""
    bendo_datastream = Bendo::DatastreamPresenter.new(datastream: content)
    location = bendo_datastream.location if bendo_datastream.valid?
    return location
  end

  def parse_xml(xml_doc)
    data = {}
    data['access'] = {}
    root = xml_doc.root
    root.elements.each do |element|
      predicate = element.name
      subject = element.text
      case predicate
      when 'representative'
        next if subject.blank?
        data[predicate] = use_url_if_is_a_pid(subject, url_type: :download)
      when 'access'
        this_access = process_access_rights(element)
        data['access'].merge!(this_access) unless this_access.empty?
      when 'embargo'
        this_access = process_embargo(element)
        data['access'].merge!(this_access) unless this_access.empty?
      else
        # TODO: Do we need to add a case: when 'copyright'? Or is it always blank?
        next if subject.blank?
        data[predicate] = use_url_if_is_a_pid(subject, url_type: :show)
      end
    end
    data
  end

  def process_access_rights(this_access)
    data = {}
    %w(read edit).each do |access|
      next unless this_access.attribute('type').to_s == access
      next if this_access.nil?
      %w(group person).each do |access_via|
        next if this_access.elements['machine'].elements[access_via].nil?
        predicate = find_access_predicate_for("#{access + access_via}")
        data[predicate] = []
        this_access.elements['machine'].elements.each do |access_via_element|
          next unless access_via_element.name == access_via
          data[predicate] << access_via_element.text
        end
      end
    end
    data
  end

  def process_embargo(this_access)
    data = {}
    unless this_access.elements['machine'].elements['date'].nil?
      predicate = "embargoDate"
      this_access.elements['machine'].elements['date'].each do |this_embargo|
        data[predicate] = this_embargo.to_s
      end
    end
    data
  end

  def parse_triples(stream)
    data = {}
    RDF::NTriples::Reader.new(stream) do |reader|
      begin
        reader.each_statement do |statement|
          predicate = delete_prefix(string: statement.predicate.to_s)
          subject = statement.object.to_s
          if !subject.blank?
            data[predicate] = use_url_if_is_a_pid(subject, url_type: :show)
          end
        end
      rescue RDF::ReaderError => e
      end
    end
    data
  end

  def parse_rdfxml(stream)
    data = {}
    data['access'] = {}
    RDF::RDFXML::Reader.new(stream).each do |thing|
      key = thing.predicate.to_s.split('#')[1]
      predicate = find_access_predicate_for(key)
      subject = thing.object.to_s.split('/')[1]
      if subject.starts_with?('afmodel')
        subject = subject.sub('afmodel:', "")
      end
      if predicate.nil?
        data[key] = use_url_if_is_a_pid(subject, url_type: :show)
      else
        data['access'][predicate] = Array.wrap(use_url_if_is_a_pid(subject, url_type: :show))
      end
    end
    data
  end

  def delete_prefix(string:)
    TERMS.each do |prefix|
      if string.starts_with?(prefix)
        return string.sub(prefix, "")
      end
    end
    string
  end

  ACCESS_PREDICATES = {
      'access' => 'access'.freeze,
      'readperson' => 'readPerson'.freeze,
      'readgroup' => 'readGroup'.freeze,
      'editperson' => 'editPerson'.freeze,
      'editgroup' => 'editGroup'.freeze,
      'embargo' => 'embargoDate'.freeze,
      'hasEditorGroup' => 'editGroup'.freeze,
      'hasViewerGroup' => 'readGroup'.freeze,
      'hasViewer' => 'readPerson'.freeze,
      'hasEditor' => 'editPerson'.freeze
  }
  def find_access_predicate_for(element)
    ACCESS_PREDICATES.fetch(element, nil)
  end

  def merge_hashes(h1, h2)
    merged = MergeHash.new.merge_hashes(h1, h2)
    merged
  end

  def use_url_if_is_a_pid(subject, url_type: :show)
    return url_for(pid: subject, url_type: url_type) if subject.starts_with?('und:')
    subject
  end

  def url_for(pid:, url_type: :show)
    id = Sufia::Noid.noidify(pid)
    url_type case
    when :show
      return File.join(root_url, route_helper.api_item_path(id))
    when :download
      return File.join(root_url, route_helper.api_item_download_path(id))
    when :thumbnail
      return File.join(root_url, route_helper.api_item_download_path(thumbnail_id), '/thumbnail')
    else # default is show
      return File.join(root_url, route_helper.api_item_path(id))
    end
  end

  def root_url
    Rails.configuration.application_root_url
  end

  def route_helper
    Rails.application.routes.url_helpers
  end
end
