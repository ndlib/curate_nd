require 'csv'

module Metrics
  class UsageController < CommonObjectsController
    respond_to(:html, :csv)
    attr_reader :curation_concern, :usage_details

    # GET /usage/:id
    def show
      noid = Sufia::Noid.noidify(params[:id])
      if curation_concern.nil?
        redirect_to root_url, notice: "Unable to display usage. Item #{noid} not found."
      else
        respond_to do |format|
          format.html { parsed_usage_details(noid: noid) }
          format.csv { send_data format_for_csv(noid: noid), filename: "#{noid}-#{Time.now}.csv" }
        end
      end
    end

    private

    # note: Metrics uses noid as the item pid
    def usage_query(pid:)
      @usage_query ||= FedoraAccessEvent.all_usage_including_child_objects_for(pid: pid)
    end

    def format_for_csv(noid:)
      usage_query(pid: noid).to_csv
    end

    def parsed_usage_details(noid:)
      @usage_details ||= begin
        parse_usage(usage: usage_query(pid: noid))
      end
    end

    def curation_concern
      @curation_concern ||= begin
        ActiveFedora::Base.load_instance_from_solr(params[:id])
      rescue ActiveFedora::ObjectNotFoundError => e
        Sentry.capture_exception(e)
        nil
      end
    end

    # @param usage [Array<FedoraAccessEvent>] an array of Metrics::FedoraAccessEvent
    # @return [Array<UsageItem>] an array of Metrics::UsageItems
    def parse_usage(usage:)
      pid_list = usage ? usage.all.group(:pid).pluck(:pid) : []
      usage_array = []
      pid_list.each do |pid|
        item_events = usage.where(pid: pid)
        usage_array << UsageItem.new(noid: pid, metrics: item_events) if item_events.any?
      end
      usage_array
    end
  end

  # A class to organize the events and usage counts for one pid
  class UsageItem
    attr_reader :noid, :label, :events

    # @param metrics [Metrics::UsageEvent]
    def initialize(noid:, metrics:)
      @noid = noid # String
      @label = item_label(noid: noid) # String
      @events = item_events(events: metrics) # Array<Metrics::ItemUsageEvent>
    end

    # @param noid [String] noid of item
    # @return [String] Title of item
    def item_label(noid:)
      id = Sufia::Noid.namespaceize(noid)
      begin
        item = ActiveFedora::Base.load_instance_from_solr(id)
        item_type = item.human_readable_type
        item_type = "File" if item_type == "Generic File"
        return "#{item_type}: #{item}"
      rescue ActiveFedora::ObjectNotFoundError
        return nil
      end
    end

    # Group events for a single noid by view and download, and organize counts for display
    # @param events [Metrics::FedoraAccessEvent::ActiveRecord_Relation] a query result list of Metrics::FedoraAccessEvent for one noid
    # @return [Array<UsageItemEvent>]
    ItemUsageEvent = Struct.new(:event, :usage_30, :usage_year, :usage_all)
    def item_events(events:)
      event_list = []
      events.all.group(:event).pluck(:event).each do |event|
        accesses = events.all.where(event: event)
        event_list << ItemUsageEvent.new(
                        event,
                        Metrics::FedoraAccessEvent.count_by(accesses: accesses, number: 30, interval: :days),
                        Metrics::FedoraAccessEvent.count_by(accesses: accesses, number: 365, interval: :days),
                        Metrics::FedoraAccessEvent.count_by(accesses: accesses)
                      ) if accesses.count > 0
      end
      event_list
    end
  end
end
