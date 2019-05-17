require 'json'
require 'rexml/document'

# Responsible for generating the JSON document for the api show response
# (based on as_jsonld_mapper)
class Api::ShowItemPresenter
  CONTEXT = {
      'und'.to_sym => File.join(Rails.configuration.application_root_url, 'show/'),
      'bibo'.to_sym => 'http://purl.org/ontology/bibo/',
      'dc'.to_sym => 'http://purl.org/dc/terms/',
      'ebucore'.to_sym => 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#',
      'foaf'.to_sym => 'http://xmlns.com/foaf/0.1/',
      'mrel'.to_sym => 'http://id.loc.gov/vocabulary/relators/',
      'nd'.to_sym => 'https://library.nd.edu/ns/terms/',
      'rdfs'.to_sym => 'http://www.w3.org/2000/01/rdf-schema#',
      'vracore'.to_sym => 'http://purl.org/vra/',
      'frels'.to_sym => 'info:fedora/fedora-system:def/relations-external#',
      'ms'.to_sym => 'http://www.ndltd.org/standards/metadata/etdms/1.1/',
      'pav'.to_sym => 'http://purl.org/pav/',
      'fedora-model'.to_sym => 'info:fedora/fedora-system:def/model#',
      'hydra'.to_sym => 'http://projecthydra.org/ns/relations#',
      'hasModel'.to_sym => { '@id' => 'fedora-model:hasModel', '@type' => '@id' },
      'hasEditor'.to_sym => { '@id' => 'hydra:hasEditor', '@type' => '@id' },
      'hasEditorGroup'.to_sym => { '@id' => 'hydra:hasEditorGroup', '@type' => '@id' },
      'hasViewer'.to_sym=>{'@id'=>'hydra:hasViewer', '@type'=>'@id'},
      'hasViewerGroup'.to_sym=>{'@id'=>'hydra:hasViewerGroup', '@type'=>'@id'},
      'isPartOf'.to_sym => { '@id' => 'frels:isPartOf', '@type' => '@id' },
      'isMemberOfCollection'.to_sym => { '@id' => 'frels:isMemberOfCollection', '@type' => '@id' },
      'isEditorOf'.to_sym => { '@id' => 'hydra:isEditorOf', '@type' => '@id' },
      'hasMember'.to_sym => { '@id' => 'frels:hasMember', '@type' => '@id' },
      'previousVersion'.to_sym => 'http://purl.org/pav/previousVersion'
  }

  DEFAULT_ATTRIBUTES = {
      'read-person' => 'nd:accessRead'.freeze,
      'read-group' => 'nd:accessReadGroup'.freeze,
      'edit-person' => 'nd:accessEdit'.freeze,
      'edit-groups' => 'nd:accessEditGroup'.freeze,
      'embargo' => 'nd:accessEmbargoDate'.freeze,
      'depositor' => 'nd:depositor'.freeze,
      'owner' => 'nd:owner'.freeze,
      'representative' => 'nd:representativeFile'.freeze
  }

  AF_MODEL_KEY = "nd:afmodel".freeze
  #Additional metadata fields
  BENDO_KEY = "nd:bendoitem".freeze
  BENDO_CONTENT_KEY = "nd:bendocontent".freeze
  FILENAME_KEY = "nd:filename".freeze
  CONTENT_KEY = "nd:content".freeze
  THUMBNAIL_KEY = "nd:thumbnail".freeze
  CONTENT_MIME_TYPE_KEY = "nd:mimetype".freeze
  CHARACTERIZATION_KEY = "nd:characterization".freeze

  def initialize(item, request_url)
    @item = item
    @attribute_map = DEFAULT_ATTRIBUTES
    @graph = RDF::Graph.new
    self.item_uri_term = RDF::URI.new("info:fedora/#{item.pid}")
    @request_url = RDF::URI.new(request_url)
    build_json!
  end

  # @return [String] the JSON document
  def to_json
    JSON.dump(@json)
  end

  # @return [Hash] a Ruby Hash of the JSON document
  def as_json
    @json
  end

  private

  def process_item_content
    item.generic_files.each do |file|
      process_datastreams(file)
    end
  end

  def build_json!
    process_datastreams(item)
    process_item_content
    json_document = strip_info_fedora_prefix(generate_json_output)
    json = JSON.parse(json_document)
    json['@context'] = unescape_json_context(json['@context'])
    @json = json
  end

  attr_accessor :item, :item_uri_term, :graph, :attribute_map

  REGEXP_FOR_UNESCAPED_JSON = /\{[^\}]*\}/.freeze

  # Because the Hash in the above context is being converted to a string via JSON::LD::Context::TermDefinition initialization,
  # I need a method to convert that String back into a hash.
  def unescape_json_context(context)
    context.each_with_object({}) do |(context_key, context_value) , new_context|
      if context_value =~ REGEXP_FOR_UNESCAPED_JSON
        new_context[context_key] = JSON.load(context_value.gsub('=>', ': '))
      else
        new_context[context_key] = context_value
      end
      new_context
    end
  end

  def process_datastreams(object)
    object.datastreams.each do |dsname, ds|
      next if dsname == 'DC'
      method_key = "process_#{dsname.gsub('-', '')}".to_sym
      if respond_to?(method_key, true)
        self.send(method_key, ds)
      else
        Rails.logger.error("#{item.pid}: unknown datastream #{dsname}")
      end
    end
  end

  def generate_json_output
    JSON::LD::Writer.buffer(prefixes: CONTEXT) do |writer|
      graph.each_statement do |statement|
        writer << statement
      end
    end
  end

  def strip_info_fedora_prefix(document)
    document.gsub(/info:fedora\/und:/, 'und:')
  end

  def process_descMetadata(ds)
    data = ds.datastream_content.force_encoding('utf-8')
    # Why the graph? Without the graph, the generate_json_output does not generate the correct
    # graph data. This was the easiest mechanism for ensuring what appears to be a more proper
    # construction of the resulting graph the same output
    graph.from_ntriples(data, format: :ntriples)
  end

  def process_RELSEXT(ds)
    data = ds.datastream_content.force_encoding('utf-8')
    # I would love to be able to use `graph.from_rdfxml(data)`, however, we need to coerce one of the nodes into the nd:afmodel
    # Thus I cannot accept all of the statements outright
    # graph.from_rdfxml(data)
    # return
    reader = RDF::RDFXML::Reader.new(data)
    reader.each_statement do |statement|
      if statement.predicate.to_s =~ /#hasModel$/i
        object = statement.object.to_s.sub("info:fedora/afmodel:", '')
        graph << RDF::Statement.new(item_uri_term, 'nd:afmodel', object)
      else
        graph << statement
      end
    end
  end

  def process_rightsMetadata(ds)
    # rights is an XML document
    # the access array may have read or edit elements
    # each of these elements may contain group or person elements
    xml_doc = REXML::Document.new(ds.datastream_content)
    root = xml_doc.root

    %w(read edit).each do |access|
      this_access = root.elements["//access[@type=\'#{access}\']"]

      next if this_access.nil?
      %w(group person).each do |access_via|
        next if this_access.elements['machine'].elements[access_via].nil?
        access_predicate_name = extract_context_name_for("#{access}-#{access_via}")
        this_access.elements['machine'].elements[access_via].each do |access_via_element|
          graph << RDF::Statement.new(item_uri_term, access_predicate_name, access_via_element.to_s)
        end
      end
    end

    unless root.elements['embargo'].elements['machine'].elements['date'].nil?
      embargo_predicate_name = extract_context_name_for("embargo")
      root.elements['embargo'].elements['machine'].elements['date'].each do |this_embargo|
        graph << RDF::Statement.new(item_uri_term, embargo_predicate_name, this_embargo.to_s)
      end
    end
  end

  def process_properties(ds)
    xml_doc = REXML::Document.new(ds.datastream_content)
    root = xml_doc.root
    root.each_element do |element|
      predicate = extract_context_name_for(element.name)
      if element.name.eql?('representative')
        statement_object = RDF::URI.new(element.text.to_s)
      else
        statement_object = element.text.to_s
      end
      graph << RDF::Statement.new(item_uri_term, predicate, statement_object)
    end
  end

  CHARACTERIZATION_PREDICATE_NAME = "nd:characterization".freeze
  def process_characterization(ds)
    return unless ds.datastream_content.present?
    graph << RDF::Statement.new(item_uri_term, CHARACTERIZATION_PREDICATE_NAME, ds.datastream_content)
  end

  BENDO_PREDICATE_NAME = "nd:bendoitem".freeze
  def process_bendoitem(ds)
    return unless ds.datastream_content.present?
    graph << RDF::Statement.new(item_uri_term, BENDO_PREDICATE_NAME, ds.datastream_content)
  end

  THUMBNAIL_PREDICATE_NAME = "nd:thumbnail".freeze
  def process_thumbnail(ds)
    thumbnail_url = File.join(Rails.configuration.application_root_url, "/downloads/",  item.noid, "/thumbnail")
    graph << RDF::Statement.new(item_uri_term, THUMBNAIL_PREDICATE_NAME, RDF::URI.new(thumbnail_url))
  end

  BENDO_CONTENT_PREDICATE_NAME = "nd:bendocontent".freeze
  FILENAME_PREDICATE_NAME = "nd:filename".freeze
  CONTENT_PREDICATE_NAME = "nd:content".freeze
  CONTENT_MIME_TYPE_PREDICATE_NAME = "nd:mimetype".freeze
  def process_content(ds)
    content_url = File.join(Rails.configuration.application_root_url, "/downloads/", item.noid)
    graph << RDF::Statement.new(item_uri_term, FILENAME_PREDICATE_NAME, ds.label)
    graph << RDF::Statement.new(item_uri_term, CONTENT_PREDICATE_NAME, content_url)
    graph << RDF::Statement.new(item_uri_term, CONTENT_MIME_TYPE_PREDICATE_NAME, ds.mimeType)
    bendo_url = bendo_location(ds.datastream_content)
    graph << RDF::Statement.new(item_uri_term, BENDO_CONTENT_PREDICATE_NAME, bendo_url) unless bendo_url.blank?
  end

  def extract_context_name_for(attribute)
    attribute_map.fetch(attribute, attribute)
  end

  def bendo_location(content)
    location = ""
    bendo_datastream = Bendo::DatastreamPresenter.new(datastream: content)
    location = bendo_datastream.location if bendo_datastream.valid?
    return location
  end
end
