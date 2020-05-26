require 'spec_helper'
require 'equivalent-xml/rspec_matchers'

 describe PropertiesDatastream do

   it "should have import_url" do
    subject.import_url = 'http://example.com/somefile.txt'
    expect(subject.import_url).to eq(['http://example.com/somefile.txt'])
    expect(subject.ng_xml.to_xml).to be_equivalent_to("<?xml version=\"1.0\"?><fields><importUrl>http://example.com/somefile.txt</importUrl></fields>")
  end

   describe "to_solr" do
    before do
      @doc = PropertiesDatastream.new.tap do |ds|
        ds.import_url = 'http://example.com/somefile.txt'
      end
    end
    subject { @doc.to_solr}
    it "should have import_url" do
      expect(subject['import_url_ssim']).to eq(['http://example.com/somefile.txt'])
    end
  end
end
