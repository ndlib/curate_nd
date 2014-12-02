require 'simple_form/form_builder'
class CurationConcernFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, override_options = {}, &block)
    # options = object.input_options_for(attribute_name, override_options)
    super(attribute_name, override_options, &block)
  end
end