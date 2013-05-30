require 'active_attr'
module ActiveFedora
  module DelegateAttributes
    class Attribute

      attr_reader :name, :datastream, :validates
      delegate :[], to: :options

      def initialize(name, options = {})
        @options = options.symbolize_keys
        @options.assert_valid_keys(:default, :datastream, :validates, :at, :multiple, :writer, :reader)
        @name = name
        @options[:multiple] = true unless @options.key?(:multiple)
      end

      def options_for_delegation
        {
          to: options[:datastream],
          at: options[:at],
          unique: !options[:multiple]
        }
      end

      def options_for_validation
        options[:validates] || {}
      end

      def default(context)
        this_default = options[:default]
        case
        when this_default.respond_to?(:call) then context.instance_exec(&this_default)
        when this_default.duplicable? then this_default.dup
        else this_default
        end
      end

      def wrap_writer_method(context)
        with_writer_method_wrap do |method_name, block|
          context.instance_exec do
            original_method = instance_method(method_name)
            define_method(method_name) do |*args|
              original_method.bind(self).call(instance_exec(*args, &block))
            end
          end
        end
      end

      def wrap_reader_method(context)
        with_reader_method_wrapper do |method_name, block|
          context.instance_exec do
            original_method = instance_method(method_name)
            define_method(method_name) do |*args|
              instance_exec(original_method.bind(self).call(*args), &block)
            end
          end
        end
      end

      private

        def with_writer_method_wrap
          if writer = options[:writer]
            method_name = "#{name}=".to_sym
            proc = writer.respond_to?(:call) ?
              writer :
              lambda { |value| send(writer, value) }
            yield(method_name, proc)
          end
        end

        def with_reader_method_wrapper
          if reader = options[:reader]
            method_name = "#{name}".to_sym
            proc = reader.respond_to?(:call) ?
              reader :
              lambda { |value| send(reader, value) }
            yield(method_name, proc)
          end
        end

        def options
          @options
        end

    end

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
