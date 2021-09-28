module CurationConcern
  module RemotelyIdentifiedByDoi

    GET_ONE = 'get_one'
    NOT_NOW = 'not_now'
    ALREADY_GOT_ONE = 'already_got_one'

    # What does it mean to be remotely assignable; Exposing the attributes
    module Attributes
      extend ActiveSupport::Concern
      included do
        include ActiveFedora::RegisteredAttributes
        attribute :doi,
          datastream: :descMetadata,
          multiple: false
        attribute :doi_assignment_strategy,
          multiple: false
        attribute :existing_identifier,
          multiple: false, 
          writer: lambda {|value| normalize_identifier(value) }

        validate :remove_white_space_in_doi

        alias_method :identifier, :doi
        alias_method :identifier=, :doi=

        attr_writer :doi_remote_service

        # desc_metadata__doi_tesim is added automatically to solr (via active_fedora perhaps?) 
        # This insures that desc_metadata__identifier_tesim is also present for backward compatibility.
        def to_solr(solr_doc = {})
          super
          solr_doc['desc_metadata__identifier_tesim'] = self.doi
          solr_doc
        end

        protected

        def normalize_identifier(value)
          doi_remote_service.normalize_identifier(value)
        end

        def doi_remote_service
          @doi_remote_service ||= Doi::Datacite
        end

        def remote_doi_assignment_strategy?
          doi_assignment_strategy == CurationConcern::RemotelyIdentifiedByDoi::GET_ONE
        end

        def doi_minting_worker
          @doi_minting_worker ||= DoiMintingWorker.new(self.pid)
        end

        private

        def remove_white_space_in_doi
          self.doi.gsub!(' ', '') if self.respond_to?(:doi) && self.doi.present?
        end
      end
    end

    module MintingBehavior

      def apply_doi_assignment_strategy(actor, &perform_persistence_block)
        if respond_to?(:doi_assignment_strategy)
          no_doi_assignment_strategy_given(&perform_persistence_block) ||
            not_now(&perform_persistence_block) ||
            update_identifier_locally(&perform_persistence_block) ||
            request_remote_minting_for(actor, &perform_persistence_block)
        else
          !!yield(self)
        end
      end


      private

      def request_remote_minting_for(actor)
        return false unless remote_doi_assignment_strategy?
        # Before we make a potentially expensive call
        # hand off control back to the caller.
        # I'm doing this because I want a chance to persist the object first
        !!yield(self) && send_doi_minting_request && actor.append_returning_message( NotificationMessage.new( :minting_doi, self.pid ) )
      end

      def send_doi_minting_request
        Sufia.queue.push(doi_minting_worker)
      end

      def update_identifier_locally
        return false unless doi_assignment_strategy == CurationConcern::RemotelyIdentifiedByDoi::ALREADY_GOT_ONE
        # I'm doing this because before I persist, I want to update the
        # identifier
        self.identifier = existing_identifier
        !!yield(self)
      end

      def no_doi_assignment_strategy_given
        return false unless doi_assignment_strategy.blank?
        !!yield(self)
      end

      def not_now
        return false unless doi_assignment_strategy.to_s == CurationConcern::RemotelyIdentifiedByDoi::NOT_NOW
        !!yield(self)
      end

    end
  end
end
