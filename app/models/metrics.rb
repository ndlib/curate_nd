module Metrics
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :metrics_db
  end

  class FedoraAccessEvent < Metrics::Base
    self.table_name = 'fedora_access_events'
    belongs_to :fedora_object

    # t.string   "event",      limit: 255, null: false
    # t.string   "pid",        limit: 255, null: false
    # t.string   "location",   limit: 255, null: false
    # t.datetime "event_time",             null: false
    # t.string   "agent",      limit: 255, null: false
    # t.datetime "created_at",             null: false
    # t.datetime "updated_at",             null: false

    # @param pid [String] the noid of an ActiveFedora item
    # @return [Metrics::FedoraAccessEvent::ActiveRecord_Relation]
    def self.all_usage_including_child_objects_for(pid:)
      usage_events = FedoraAccessEvent.where(pid: FedoraObject.ids_of_object_and_all_child_objects_of(pid: pid))
    end

    # @param accesses [Metrics::FedoraAccessEvent::ActiveRecord_Relation] Result list of Metrics::FedoraAccessEvent query
    # @return [Fixnum]
    def self.count_by(accesses:, number: nil, interval: nil)
      @count = begin
        if (number.nil? || interval.nil?)
          accesses.all.count
        else
          accesses.all.where(event_time: number.send(interval).ago..Date.today).count
        end
      end
    end

    # @param accesses [Metrics::FedoraAccessEvent::ActiveRecord_Relation]
    def self.to_csv
      attributes = %w{pid event event_time}

      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |access|
          csv << attributes.map { |attr| access.send(attr) }
        end
      end
    end
  end

  class FedoraObject < Metrics::Base
    self.table_name = 'fedora_objects'
    has_many :fedora_access_events

    # t.string   "pid",               limit: 255,              null: false
    # t.string   "af_model",          limit: 255,              null: false
    # t.string   "resource_type",     limit: 255,              null: false
    # t.string   "mimetype",          limit: 255,              null: false
    # t.integer  "bytes",             limit: 8,                null: false
    # t.string   "parent_pid",        limit: 255,              null: false
    # t.datetime "obj_ingest_date",                            null: false
    # t.datetime "obj_modified_date",                          null: false
    # t.string   "access_rights",     limit: 255,              null: false
    # t.datetime "created_at",                                 null: false
    # t.datetime "updated_at",                                 null: false
    # t.string   "title",             limit: 255, default: ""
    # t.string   "parent_type",       limit: 255, default: ""

    def self.ids_of_object_and_all_child_objects_of(pid:)
      results = FedoraObject.where(parent_pid: pid).pluck(:pid)
      results << pid unless results.include?(pid)
      results
    end
  end
end
