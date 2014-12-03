require 'simple_form/form_builder'
class CurationConcernFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, override_options = {}, &block)
    if object.respond_to?(:input_options_for)
      options = object.input_options_for(attribute_name, override_options)
    else
      options = override_options
    end
    super(attribute_name, options, &block)
  end
end