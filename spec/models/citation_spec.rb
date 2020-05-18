require 'spec_helper'

describe Citation do
  let(:curation_concern){
    OpenStruct.new(
      {
        noid: "jq085h7459h",
        :publisher => ["University of Notre Dame"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :creator => ["John Michael Smith", "Adam Lee", "Mohammed Ahmed Sultan", "Joseph Jon Green"]
      }
    )
  }

  let(:expected_citation){
    "Smith, J. M., Lee, A., Sultan, M. A., &amp; Green, J. J. (2013). <i>This is a test title for generating test citation</i>. University of Notre Dame. https://doi.org/10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_multiple_publisher){
    OpenStruct.new(
      {
        noid: "jq085h7459h",
        :publisher => ["University of Notre Dame", "Indiana University"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :creator => ["John Michael Smith", "Adam Lee", "Mohammed Ahmed Sultan", "Joseph Jon Green"]
      }
    )
  }

  let(:expected_citation_with_multiple_publisher){
    "Smith, J. M., Lee, A., Sultan, M. A., &amp; Green, J. J. (2013). <i>This is a test title for generating test citation</i>. University of Notre Dame, Indiana University. https://doi.org/10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_one_author_and_adviser){
    OpenStruct.new(
      {
        noid: "jq085h7459h",
        :publisher => ["University of Notre Dame"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :creator => ["John Michael Smith"] | ["Mohammed Ahmed Sultan"]
      }
    )
  }

  let(:expected_citation_with_one_author_and_adviser){
    "Smith, J. M., &amp; Sultan, M. A. (2013). <i>This is a test title for generating test citation</i>. University of Notre Dame. https://doi.org/10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_out_created_date){
    OpenStruct.new(
      {
        noid: "jq085h7459h",
        :publisher => ["University of Notre Dame"],
        :created => "",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :creator => ["John Michael Smith", "Mohammed Ahmed Sultan"]
      }
    )
  }

  let(:expected_citation_with_out_created_date){
    "Smith, J. M., &amp; Sultan, M. A. This is a test title for generating test citation. University of Notre Dame. https://doi.org/10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_no_doi){
    OpenStruct.new(
      {
        noid: "jq085h7459h",
        title: "This is a test title for generating test citation",
        publisher: ["University of Notre Dame"],
        creator: ["John Michael Smith", "Mohammed Ahmed Sultan"],
        created: nil,
        identifier: nil
      }
    )
  }

  let(:expected_citation_with_no_doi){
    "Smith, J. M., &amp; Sultan, M. A. <i>This is a test title for generating test citation</i>. University of Notre Dame. Retrieved from #{File.join(Rails.configuration.application_root_url, "/show/jq085h7459h")}"
  }

  describe "to_s" do
    it "should create citation text with the given data" do
      citation = Citation.new(curation_concern)
      expect(citation.to_s).to eq(expected_citation)
    end

    it "should create citation text with multiple publishers" do
      citation = Citation.new(curation_concern_with_multiple_publisher)
      expect(citation.to_s).to eq(expected_citation_with_multiple_publisher)
    end

    it "should create citation text with one author and adviser" do
      citation = Citation.new(curation_concern_with_one_author_and_adviser)
      expect(citation.to_s).to eq(expected_citation_with_one_author_and_adviser)
    end

    it "should create citation without created date" do
      citation = Citation.new(curation_concern_with_out_created_date)
      expect(citation.to_s).to eq(expected_citation_with_out_created_date)
    end

    it "should create citation with no doi" do
      citation = Citation.new(curation_concern_with_no_doi)
      expect(citation.to_s).to eq(expected_citation_with_no_doi)
    end
  end
end
