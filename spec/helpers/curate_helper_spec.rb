require 'spec_helper'

RSpec.describe CurateHelper do
  context '#support_email_link' do
    it 'should render a mailto link' do
      expect(helper.support_email_link).to match(%r{^<a href="mailto})
    end
  end

  context '#collection_title_from_pid' do
    let(:value) { 'abc' }
    let(:collection) { double(title: 'Title') }
    it 'should load the value and return the title' do
      allow(Collection).to receive(:load_instance_from_solr).with(value).and_return(collection)
      expect(helper.collection_title_from_pid(value)).to eq(collection.title)
    end
    it 'should attempt to load the value, fail, and return the value' do
      allow(Collection).to receive(:load_instance_from_solr).with(value).and_return(nil)
      expect(helper.collection_title_from_pid(value)).to eq(value)
    end
  end

  it 'has #default_page_title' do
    expect(helper.default_page_title).to(
      eq("#{controller_name.titleize} // #{I18n.t('sufia.product_name')}")
    )
  end

  it 'has #curation_concern_page_title' do
    expect(helper.curation_concern_page_title(GenericWork.new)).to(
      eq("New Generic Work // #{I18n.t('sufia.product_name')}")
    )
  end

  describe '#curation_concern_attribute_to_html' do
    def render_curation_concern_attribute_html(expected_label, *item_or_collection)
      collection = Array(item_or_collection).flatten.compact
      have_tag('tr') do
        with_tag("th", text: expected_label)
        with_tag('td ul.tabular') do
          if collection.present?
            collection.each do |value|
              with_tag('li.attribute.things', text: value)
            end
          else
            yield if block_given?
          end
        end
      end
    end

    it 'handles an array by rendering one <dd> per element' do
      collection = ["h2", "Johnny Tables"]
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      expect(rendered).to render_curation_concern_attribute_html('Weird', collection)
    end

    it 'handles a string by rendering one <dd>' do
      collection = "Tim"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      expect(rendered).to render_curation_concern_attribute_html('Weird', collection)
    end

    it 'returns a '' for a nil value' do
      collection = nil
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      expect(rendered).to eq("")
    end

    it 'extracts name based on attribute registry' do
      collection = "Hello World"
      object = double('curation_concern', things: collection)
      allow(object).to receive(:label_for).with(:things).and_return("Bacon")

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      expect(rendered).to render_curation_concern_attribute_html('Bacon', collection)
    end

    it 'calculates the label based on method name' do
      collection = "Hello World"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      expect(rendered).to render_curation_concern_attribute_html('Things', collection)
    end

    it 'returns a '' for an empty array' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      expect(rendered).to eq("")
    end
    it 'returns a string for an empty array if allow_empty is passed' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird", include_empty: true)
      expect(rendered).to render_curation_concern_attribute_html('Weird') do
        without_tag('li.attribute.things')
      end
    end

    context 'for #relation' do
      it 'will generate the appropriate callout text for the given link' do
        href = "http://collections.library.nd.edu/somewhere"
        curation_concern = double('Curation Concern', relation: ["Hello", href])
        callout_text = "View in DEC"
        output = helper.curation_concern_attribute_to_html(
          curation_concern, :relation, "Related Resource(s)",
          callout_pattern: /\Ahttp:\/\/collections\.library\.nd\.edu/,
          callout_text: callout_text
        )
        expect(output).to have_tag("tr td ul.tabular li.attribute.relation span.callout-text", text: callout_text, count: 1)
      end
    end
    context 'for #library_collection' do
      it 'will generate a link to the collection' do
        library_collections = [LibraryCollection.new(pid: 'und:123', title: 'Hello'), LibraryCollection.new(pid: 'und:456', title: 'World')]
        curation_concern = double('Curation Concern', library_collections: library_collections)
        output = helper.curation_concern_attribute_to_html(curation_concern, :library_collections, "Member of")
        expect(output).to have_tag("tr td ul.tabular li.attribute.library_collections a[href='/show/123']", text: 'Hello', count: 1)
        expect(output).to have_tag("tr td ul.tabular li.attribute.library_collections a[href='/show/456']", text: 'World', count: 1)
      end
    end
  end

  describe '#curation_concern_attribute_to_formatted_text' do
    it 'returns a "" for a nil value' do
      collection = nil
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things)
      expect(rendered).to eq('')
    end

    it 'returns a "" for an empty array' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things)
      expect(rendered).to eq('')
    end

    it 'calculates the label based on method name' do
      collection = 'Hello World'
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things)
      expect(rendered).to have_tag('h2', text: 'Things')
    end

    it 'handles an array by rendering one <article> per element' do
      collection = ['Unexpected', 'ALL THE THINGS']
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things)
      expect(rendered).to have_tag('article', count: 2)
    end

    it 'handles a string by rendering one <article> per element' do
      collection = 'There is no strange thing.'
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things)
      expect(rendered).to have_tag('article', count: 1)
    end

    it 'allows a custom class to be set on blocks of text' do
      collection = 'The final countdown.'
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_formatted_text(object, :things, nil, { class: 'custom-class' })
      expect(rendered).to_not have_tag('article', with: { class: 'descriptive-text' })
      expect(rendered).to have_tag('article', with: { class: 'custom-class' })
    end
  end

  it 'has #classify_for_display' do
    expect(helper.classify_for_display(GenericWork.new)).to eq('generic work')
  end

  describe '#link_to_edit_permissions' do
    let(:solr_document) {
      {
        Hydra.config[:permissions][:read][:group] => access_policy,
        Hydra.config[:permissions][:embargo_release_date] => embargo_release_date
      }
    }
    let(:user) { FactoryGirl.create(:user) }
    let(:curation_concern) {
      FactoryGirl.create_curation_concern(
        :document, user, visibility: visibility
      )
    }
    let(:visibility) { nil }
    let(:access_policy) { nil }
    let(:embargo_release_date) { nil }
    describe 'with a "registered" access group' do
      let(:expected_label) { t('sufia.institution_name') }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED } # Can we change this?
      let(:access_policy) { 'registered' }
      it 'renders an Institution only label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-info", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'with a "public" access group' do
      let(:access_policy) { 'public' }
      describe 'without embargo release date' do
        let(:expected_label) { "Public" }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Public" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end

      describe 'with an embargo release date' do
        let(:expected_label) { "Embargo then Public" }
        let(:embargo_release_date) { Date.today.to_s }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Embargo then Public" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-warning", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end
    end

    describe 'with a mixed "public registered" access group' do
      # This test is purely speculative to the appropriate labeling behavior and
      # does not account for whether the document is truly accessable; I suppose
      # I'm persisting hash drive development via a Solr document
      let(:expected_label) { "Public" }
      let(:access_policy) { 'public registered' }
      it 'renders an "Public" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'without an access group' do
      let(:expected_label) { "Private" }
      let(:access_policy) { nil }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'renders an "Private" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-important", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
  end

  describe '#richly_formatted_text' do
    # This is a token test. Curate::TextFormatter is tested elsewhere.
    let(:text) { "This text should be returned in two paragraphs.\n\nYes no?" }
    it 'parses basic text formatting' do
      rendered = helper.richly_formatted_text(text)
      expect(rendered).to(
        have_tag('p', count: 2)
      )
    end
  end

  it "should have link for google.com" do
    expect(helper.auto_link_without_protocols("google.com")).to have_link("http://google.com")
  end
end
