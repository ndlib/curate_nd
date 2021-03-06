module Curate

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    def initialize
      @all_relationships_reindexer = default_all_relationships_reindexer
      @relationship_reindexer = default_relationship_reindexer
    end
    attr_accessor :all_relationships_reindexer, :relationship_reindexer


    # An anonymous function that receives a path to a file
    # and returns AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE if no
    # virus is found; Any other returned value means a virus was found
    attr_writer :default_antivirus_instance
    def default_antivirus_instance
      @default_antivirus_instance ||= lambda {|file_path|
        AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
      }
    end

    def default_all_relationships_reindexer
      lambda {
        require 'all_relationships_reindexing_worker'
        Sufia.queue.push(AllRelationshipsReindexerWorker.new)
        true
      }
    end

    def default_relationship_reindexer
      lambda { |pid|
        require 'object_relationship_reindexing_worker'
        Sufia.queue.push(ObjectRelationshipReindexerWorker.new(pid))
        true
      }
    end

    # Configure default search options from config/search_config.yml
    attr_writer :search_config
    def search_config
      @search_config ||= "search_config not set"
    end

    # Configure the application root url.
    attr_writer :application_root_url
    def application_root_url
      @application_root_url || (raise RuntimeError.new("Make sure to set your Curate.configuration.application_root_url"))
    end

    # When was this last built/deployed
    attr_writer :build_identifier
    def build_identifier
      # If you restart the server, this could be out of sync; A better
      # implementation is to read something from the file system. However
      # that detail is an exercise for the developer.
      @build_identifier ||= Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def fedora_integrity_message_delivery
      @fedora_integrity_message_delivery ||= default_fedora_integrity_message_delivery
    end

    def fedora_integrity_message_delivery=(callable)
      if callable.respond_to?(:call)
        @fedora_integrity_message_delivery = callable
      else
        raise RuntimeError, "Expected #{callable.inspect} to respond_to :call"
      end
    end

    # Override characterization runner
    attr_accessor :characterization_runner

    def register_curation_concern(*curation_concern_types)
      Array(curation_concern_types).flatten.compact.each do |cc_type|
        class_name = ClassifyConcern.normalize_concern_name(cc_type)
        if ! registered_curation_concern_types.include?(class_name)
          self.registered_curation_concern_types << class_name
        end
      end
    end

    # Returns the class names (strings) of the registered curation concerns
    def registered_curation_concern_types
      @registered_curation_concern_types ||= []
    end

    # Returns the classes of the registered curation concerns
    def curation_concerns
      registered_curation_concern_types.map(&:constantize)
    end

    def default_fedora_integrity_message_delivery
      lambda do |options|
        pid = options.fetch(:pid)
        message = options.fetch(:message)
        $stderr.puts "----------- Problem with #{pid}, Message:#{message} ----------"
      end
    end
    private :default_fedora_integrity_message_delivery
  end

  configure {}
end
