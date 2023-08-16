require 'spec_helper'
require 'controlled_vocabulary_service'

RSpec.describe ControlledVocabularyService do
  let(:predicate_name) { 'copyright' }
  let(:label_value) { "CC0 1.0 Universal" }
  let(:uri) { "http://creativecommons.org/publicdomain/zero/1.0/" }

  describe '.item_for_predicate_name' do
    let(:subject) do
      described_class.item_for_predicate_name(name: predicate_name,
                                              term_key: 'term_label',
                                              term_value: label_value,
                                              ignore_not_found: ignore)
    end
    let(:ignore) { false }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:item_for).with(predicate_name: predicate_name, search_term_key: 'term_label', search_term_value: label_value).and_call_original
      expect(subject).to be_a(Locabulary::Items::Base)
    end

    context 'if item not found' do
      let(:label_value) { 'abcdefg' }
      context 'with error reporting' do
        let(:ignore) { false }
        it 'returns nil' do
          expect(subject).to eq(nil)
        end
      end
      context 'with error supression' do
        let(:ignore) { true }
        it 'returns nil' do
          expect(subject).to eq(nil)
        end
        it 'bypasses error reporting' do
          expect(Sentry).not_to receive(:capture_exception)
          subject
        end
      end
    end
  end

  describe '.labels_for_predicate_name' do
    let(:subject) { described_class.labels_for_predicate_name(name: name) }

    context 'for predicates in locabulary' do
      let(:name) { predicate_name }

      it 'calls Locabulary' do
        expect(Locabulary).to receive(:all_labels_for).with(predicate_name: predicate_name).and_call_original
        expect(subject).to be_a(Array)
        expect(subject.first).to be_a(String)
      end
    end

    context 'for predicates not in locabulary' do
      let(:name) { 'degree_level' }

      it 'returns local values' do
        expect(Locabulary).not_to receive(:all_labels_for)
        expect(subject).to eq(ControlledVocabularyService::DEGREE_LEVELS)
        expect(subject).to be_a(Array)
        expect(subject.first).to be_a(String)
      end
    end
  end

  describe '.active_entries_for_predicate_name' do
    let(:subject) { described_class.active_entries_for_predicate_name(name: predicate_name) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:active_items_for).with(predicate_name: predicate_name, as_of: kind_of(Time)).and_call_original
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(Locabulary::Items::Base)
    end
  end

  describe '.all_entries_for_predicate_name' do
    let(:subject) { described_class.all_entries_for_predicate_name(name: predicate_name) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:all_items_for).with(predicate_name: predicate_name).and_call_original
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(Locabulary::Items::Base)
    end
  end

  describe '.label_from_uri' do
    let(:subject) { described_class.label_from_uri(name: predicate_name, uri: uri) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:active_label_for_uri).with(predicate_name: predicate_name, term_uri: uri).and_call_original
      expect(subject).to be_a(String)
    end
  end

  describe '.active_hierarchical_roots' do
    let(:name) { 'administrative_units' }
    let(:as_of) { Time.zone.now }
    let(:subject) { described_class.active_hierarchical_roots(name: name, as_of: as_of) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:active_hierarchical_roots).with(predicate_name: name, as_of: as_of).and_call_original
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(Locabulary::Items::Base)
    end
  end

  describe '.hierarchical_menu_options' do
    let(:name) { 'administrative_units' }
    let(:as_of) { Time.zone.now }
    let(:roots) { described_class.active_hierarchical_roots(name: name, as_of: as_of) }
    let(:subject) { described_class.hierarchical_menu_options(roots: roots) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:hierarchical_menu_options).with(roots: roots).and_call_original
      expect(subject).to be_a(Array)
      expect(subject.first).to be_a(Hash)
    end
  end

  describe '.build_ordered_hierarchical_tree' do
    let(:name) { 'administrative_units' }
    let(:item1) { double( value: "abc", hits: 4 ) }
    let(:item2) { double( value: "def", hits: 2 ) }
    let(:items) { [ item1, item2 ] }
    let(:delimiter) { ':' }
    let(:subject) { described_class.build_ordered_hierarchical_tree(name: name, items: items, delimiter: delimiter) }

    it 'calls Locabulary' do
      expect(Locabulary).to receive(:build_ordered_hierarchical_tree).with(faceted_items: items, faceted_item_hierarchy_delimiter: delimiter,
      predicate_name: name).and_call_original
      expect(subject).to be_a(Array)
    end
  end
end
