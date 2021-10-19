

RSpec.describe DataciteMapper do
  let(:remapped_hash) { { id: 1 } }
  let(:subject) { DataciteMapper.call(curation_concern) }

  before do
    allow(Curate).to receive(:permanent_url_for).and_return('purl')
  end

  [SeniorThesis, Dataset, Image, Document, Article, Etd, CatholicDocument, Audio, Video, Dissertation].each do |model|
    context "when called with a #{model}" do
      let(:curation_concern) { model.new(creator: 'Creator', date_uploaded: Date.parse('1/1/1999')) }

      it 'makes it public' do
        expect(subject[:data][:attributes]).to include(event: 'publish')
      end

      it 'uses the Curate.permanent_url_for for the target' do
        expect(subject[:data][:attributes]).to include(url: 'purl')
      end

      it 'specifies a resource type of Other/CreativeWork' do
        expect(subject[:data][:attributes][:types]).to include(resourceType: 'CreativeWork')
        expect(subject[:data][:attributes][:types]).to include(resourceTypeGeneral: 'Other')
      end

      it 'maps the object creator to the creator field' do
        expect(subject[:data][:attributes][:creators]).to include(name: curation_concern.creator.first)
      end

      describe 'when the model supports multiple creators and it has multiple creators', unless: model.name == "SeniorThesis" do
        let(:curation_concern) { model.new(creator: ['Creator 1', 'Creator 2'], date_uploaded: Date.parse('1/1/1999')) }

        it 'maps the an array of creators to the creator field as a string' do
          expect(subject[:data][:attributes][:creators]).to include(name: 'Creator 1, Creator 2')
        end
      end

      it 'maps the object title to the title field' do
        expect(subject[:data][:attributes][:titles]).to include(title: curation_concern.title)
      end

      it 'specifies our institution name as publisher' do
        expect(subject[:data][:attributes]).to include(publisher: "University of Notre Dame")
      end

      it 'maps the object date_uploaded to the publication_year' do
        expect(subject[:data][:attributes]).to include(publicationYear: curation_concern.date_uploaded.year)
      end
    end
  end
end
