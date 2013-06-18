require 'active_attr'
require File.expand_path('../delegate_attributes/attribute', __FILE__)
module ActiveFedora
  module DelegateAttributes
    extend ActiveSupport::Concern
    included do
      class_attribute :delegate_attributes, instance_writer: false, instance_reader: false
    end

    module ClassMethods
      def attribute(attribute_name, options ={})
        attribute = Attribute.new(attribute_name, options)

        self.delegate_attributes ||= {}
        self.delegate_attributes[attribute.name] = attribute

        validates(attribute.name, attribute.options_for_validation) if attribute.options_for_validation.present?
        delegate(attribute.name, attribute.options_for_delegation)

        attribute.wrap_writer_method(self)
        attribute.wrap_reader_method(self)
      end
    end

    def input_options_for(attribute_name, override_options)
      attribute_config(attribute_name).options_for_input(override_options)
    rescue KeyError
      override_options
    end

    def attribute_config(name)
      self.class.delegate_attributes.fetch(name)
    end

    # Applies the attribute defaults
    #
    # Applies all the default values to any attributes not yet set, avoiding
    # any attribute setter logic, such as dirty tracking.
    #
    # @param [Hash{String => Object}, #each] defaults The defaults to apply
    def apply_defaults(defaults=attribute_defaults)
      defaults.each do |name, value|
        unless value.nil?
          send("#{name}=", value) unless send("#{name}").present?
        end
      end
    end

    # Calculates the attribute defaults from the attribute definitions
    #
    # @return [Hash{String => Object}] the attribute defaults
    def attribute_defaults
      self.class.delegate_attributes.collect { |name, attribute| [name, attribute.default(self)] }
    end

    # Applies attribute default values
    def initialize(*)
      super
      apply_defaults
    end

  end
end
