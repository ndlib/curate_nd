require 'spec_helper'

describe ActiveFedora::DelegateAttributes::Attribute do
  let(:name) { :title }
  let(:datastream) { 'SourApple' }
  let(:options) { {datastream: datastream, hint: 'Your title', form: { input_html: {style: 'title-picker'}} } }
  subject { ActiveFedora::DelegateAttributes::Attribute.new(name, options) }
  it 'has #options_for_delegation' do
    expect(subject.options_for_delegation).to eq({to: datastream, unique: false})
  end

  it 'has #options_for_input' do
    expect(subject.options_for_input(input_html: {size: 10})).to eq(
      {
        hint: 'Your title', as: 'multi_value', input_html:
        {
          style: 'title-picker', multiple: 'multiple', size: 10
        }
      }
    )
  end

  it 'has #options_for_validation' do
    expect(subject.options_for_validation).to respond_to(:[])
  end
end
