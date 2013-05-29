require 'spec_helper'

describe Citation do
  let(:curation_concern){
    OpenStruct.new(
      {
        :publisher => ["University of Notre Dame"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :authors_for_citation => ["John Michael Smith", "Adam Lee"] | ["Mohammed Ahmed Sultan"] | ["Joseph Jon Green"]
      }
    )
  }

  let(:expected_citation){
    "Smith, J.M., Lee, A., Sultan, M.A., & Green, J.J.(2013, May 01). This is a test title for generating test citation. University of Notre Dame. doi:10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_multiple_publisher){
    OpenStruct.new(
      {
        :publisher => ["University of Notre Dame", "Indiana University"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :authors_for_citation => ["John Michael Smith", "Adam Lee"] | ["Mohammed Ahmed Sultan"] | ["Joseph Jon Green"]
      }
    )
  }

  let(:expected_citation_when_multiple_publisher){
    "Smith, J.M., Lee, A., Sultan, M.A., & Green, J.J.(2013, May 01). This is a test title for generating test citation. University of Notre Dame, Indiana University. doi:10.5072/FK2NS13CS"
  }

  let(:curation_concern_when_one_author_and_adviser){
    OpenStruct.new(
      {
        :publisher => ["University of Notre Dame"],
        :created => "2013-05-01",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :authors_for_citation => ["John Michael Smith"] | ["Mohammed Ahmed Sultan"]
      }
    )
  }

  let(:expected_citation_when_one_author_and_adviser){
    "Smith, J.M., & Sultan, M.A.(2013, May 01). This is a test title for generating test citation. University of Notre Dame. doi:10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_out_created_date){
    OpenStruct.new(
      {
        :publisher => ["University of Notre Dame"],
        :created => "",
        :title => "This is a test title for generating test citation",
        :identifier => "doi:10.5072/FK2NS13CS",
        :authors_for_citation => ["John Michael Smith"] | ["Mohammed Ahmed Sultan"]
      }
    )
  }

  let(:expected_citation_with_out_created_date){
    "Smith, J.M., & Sultan, M.A. This is a test title for generating test citation. University of Notre Dame. doi:10.5072/FK2NS13CS"
  }

  let(:curation_concern_with_no_doi){
    @curation_concern = mock_model(SeniorThesis)
    @curation_concern.stub!(:to_param).and_return("jq085h7459h")
    @curation_concern.stub!(:title).and_return("This is a test title for generating test citation")
    @curation_concern.stub!(:publisher).and_return(["University of Notre Dame"])
    @curation_concern.stub!(:authors_for_citation).and_return(["John Michael Smith"] | ["Mohammed Ahmed Sultan"])
    @curation_concern.stub!(:created).and_return(nil)
    @curation_concern.stub!(:identifier).and_return(nil)
    @curation_concern
  }

  let(:expected_citation_with_no_doi){
    "Smith, J.M., & Sultan, M.A. This is a test title for generating test citation. University of Notre Dame. Retrieved from #{File.join(Rails.configuration.application_url, "/show/jq085h7459h")}"
  }

  describe "to_apa" do
    it "should create citation text with the given data" do
      citation = Citation.new(curation_concern)
      citation.to_s.should == expected_citation
    end

    it "should create citation text with multiple publishers" do
      citation = Citation.new(curation_concern_with_multiple_publisher)
      citation.to_s.should == expected_citation_when_multiple_publisher
    end

    it "should create citation text with one author and adviser" do
      citation = Citation.new(curation_concern_when_one_author_and_adviser)
      citation.to_s.should == expected_citation_when_one_author_and_adviser
    end

    it "should create citation without created date" do
      citation = Citation.new(curation_concern_with_out_created_date)
      citation.to_s.should == expected_citation_with_out_created_date
    end

    it "should create citation with no doi" do
      citation = Citation.new(curation_concern_with_no_doi)
      citation.to_s.should == expected_citation_with_no_doi
    end
  end
end
