require 'spec_helper'
require 'active_fedora/delegate_attributes'

describe 'ActiveFedora::DelegateAttributes' do
  class MockDelegateAttribute < ActiveFedora::Base
    include ActiveFedora::DelegateAttributes

    has_metadata :name => "properties", :type => ActiveFedora::SimpleDatastream do |m|
      m.field "title",  :string
      m.field "description",  :string
      m.field "creator", :string
      m.field "file_names", :string
      m.field "locations", :string
      m.field "created_on", :date
      m.field "modified_on", :date
    end

    attribute :title, {
      datastream: 'properties',
      multiple: false,
      label: 'Title of your Work',
      hint: "How would you name this?",
      validates: { presence: true }
    }

    attribute :description, {
      datastream: 'properties',
      default: ['One two']
    }

    attribute :creator, {
      datastream: 'properties',
      multiple: false,
      writer: lambda{|value| value.reverse }
    }

    attribute :file_names, {
      datastream: 'properties',
      multiple: true,
      writer: lambda{|value| value.reverse }
    }

    def set_locations(value)
      value.dup << '127.0.0.1'
    end
    protected :set_locations

    attribute :locations, {
      datastream: 'properties',
      multiple: true,
      writer: :set_locations
    }

    attribute :created_on, {
      datastream: 'properties',
      multiple: false,
      reader: lambda {|value|
        "DATE: #{value}"
      }
    }

    attribute :modified_on, {
      datastream: 'properties',
      multiple: true,
      reader: lambda {|value|
        "DATE: #{value}"
      }
    }
  end
  subject { MockDelegateAttribute.new() }

  let(:reloaded_subject) { subject.class.find(subject.pid) }
  describe '#attribute_config' do
    let(:attribute_config) { subject.attribute_config(:title) }
    it do
      expect(attribute_config.options_for_delegation).to be_instance_of(Hash)
      expect(attribute_config.options_for_validation).to be_instance_of(Hash)
      expect(attribute_config.options_for_input).to be_instance_of(Hash)
    end
  end
  describe '#input_options_for' do
    let(:override_options) { {spam: true} }
    let(:attribute_config) { subject.input_options_for(:title, override_options ) }
    it 'merges the override and the input' do
      expect(attribute_config.fetch(:spam)).to eq(true)
      expect(attribute_config.fetch(:label)).to eq('Title of your Work')
    end

    it 'gracefully fails if the attribute is not configured' do
      expect(subject.input_options_for(:missing, override_options)).to eq(override_options)
    end

  end
  describe '.attribute' do
    it "has creates a setter/getter" do
      subject.title = 'Hello'
      subject.save!
      expect(reloaded_subject.title).to eq('Hello')
    end

    it "enforces validation when passed" do
      subject.title = nil
      subject.valid?
      expect(subject.errors[:title].size).to eq(1)
    end

    it "allows for default" do
      expect(subject.description).to eq(['One two'])
    end

    it "allows for a reader to intercept the returning of values" do
      date = Date.today
      subject.created_on = date
      expect(subject.properties.created_on).to eq([date])
      expect(subject.created_on).to eq("DATE: #{date}")
    end

    it "allows for a reader to intercept the returning of values" do
      date = Date.today
      subject.created_on = date
      expect(subject.properties.created_on).to eq([date])
      expect(subject.created_on).to eq("DATE: #{date}")
    end

    it "allows for a writer to intercept the setting of values" do
      text = 'hello world'
      subject.creator = 'hello world'
      expect(subject.properties.creator).to eq([text.reverse])
      expect(subject.creator).to eq(text.reverse)
    end

    it "allows for a writer to intercept the setting of values" do
      values = ['foo.rb', 'bar.rb']
      subject.file_names = values
      expect(subject.properties.file_names).to eq(values.reverse)
      expect(subject.file_names).to eq(values.reverse)
    end

    it "allows for a writer that is a symbol" do
      values = ['South Bend', 'State College', 'Minneapolis']
      expected_values = values.dup
      expected_values << '127.0.0.1'
      subject.locations = values
      expect(subject.properties.locations).to eq(expected_values)
      expect(subject.locations).to eq(expected_values)
    end
  end

end
