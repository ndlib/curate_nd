# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :inline, tag: 'span', class: 'form-group inline', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper :tag => 'span', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end
  config.wrappers :prepend, :tag => 'div', :class => "form-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-group' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "form-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-group' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.wrappers :bootstrap, :tag => 'div', :class => 'form-group', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper :tag => 'span', :class => 'control-label' do |bb|
      bb.use :label
      bb.use :hint_for_curate_nd
    end
    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input_for_curate_nd
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end

module SimpleForm
  module Components
    module Labels
      # I chose Labels because it extends ActiveSupport::Concern and thus
      # I can more readily guarantee that the below module is mixed into all
      # classes, SimpleForm::Inputs::Base and its descendant classes
      included do
        include CurateND::SimpleFormOverride::Labels
      end
    end
  end
end

module CurateND
  module SimpleFormOverride
    module Labels
      extend ActiveSupport::Concern
      # To provide the proper arialabelled-by attribute, I'm adding an ID to the
      # label that can be referenced.
      def raw_label_text
        template.content_tag('span', id: curate_nd_dom_id('label')) do
          super
        end
      end

      def hint_for_curate_nd(wrapper_options)
        return '' unless has_hint?
        template.content_tag('span', class: 'field-hint', role: 'tooltip', id: curate_nd_dom_id('hint')) do
          hint
        end
      end

      def input_for_curate_nd(wrapper_options)
        @input_html_options[:'aria-labelledby'] = curate_nd_dom_id('label')
        @input_html_options[:'aria-describedby'] = curate_nd_dom_id('hint')
        input
      end

      private

      def curate_nd_dom_id(suffix)
        "#{@builder.object_name}_#{attribute_name}_#{suffix}"
      end
    end
  end
end
