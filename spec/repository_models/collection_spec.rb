require 'spec_helper'
require 'active_fedora/test_support'
describe Collection do


  let(:user) { FactoryGirl.create(:user) }
  let(:generic_work1) { FactoryGirl.create(:generic_work, user: user, title:"My Work 1")}
  let(:generic_work2) {FactoryGirl.create(:generic_work, user: user, title:"My Fabulous Work") }

  before(:each) do
    @collection = Collection.new
    @collection.apply_depositor_metadata(user.user_key)
    @collection.save
  end
  after(:each) do
    @collection.destroy
  end
  it "should have a depositor" do
    @collection.depositor.should == user.user_key
  end
  it "should allow the depositor to edit and read" do
    ability = Ability.new(user)
    ability.can?(:read, @collection).should == true
    ability.can?(:edit, @collection).should == true
  end
  it "should be empty by default" do
    expect(@collection.members).to eq([])
  end
  it "should have many works" do
    @collection.members = [generic_work1, generic_work2]
    @collection.save
    Collection.find(@collection.pid).members.should == [generic_work1, generic_work2]
  end
  it "should allow new work to be added" do
    @collection.members = [generic_work1]
    @collection.save
    @collection = Collection.find(@collection.pid)
    @collection.members << generic_work2
    @collection.save
    Collection.find(@collection.pid).members.should == [generic_work1, generic_work2]
  end
  it "should set the date uploaded on create" do
    @collection.save
    @collection.date_uploaded.should be_kind_of(Date)
  end
  it "should update the date modified on update" do
    uploaded_date = Date.today
    modified_date = Date.tomorrow
    Date.stub(:today).and_return(uploaded_date, modified_date)
    @collection.save
    @collection.date_modified.should == uploaded_date
    @collection.members = [generic_work1]
    @collection.save
    @collection.date_modified.should == modified_date
    new_generic_work1 = GenericWork.find(generic_work1.pid)
    new_generic_work1.collections.include?(@collection).should be_truthy
    new_generic_work1.to_solr[Solrizer.solr_name(:collection)].should == [@collection.id]
  end
  it "should have a title" do
    @collection.title = "title"
    @collection.save
    Collection.find(@collection.pid).title.should == @collection.title
  end
  it "should have a description" do
    @collection.description = "description"
    @collection.save
    Collection.find(@collection.pid).description.should == @collection.description
  end
  it "should have the expected display terms" do
    @collection.terms_for_display.should == [:part_of, :contributor, :creator, :title, :description, :publisher, :administrative_unit, :curator, :date, :date_created, :date_uploaded, :date_modified, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url, :source]
  end
  it "should have the expected edit terms" do
    @collection.terms_for_editing.should == [:part_of, :contributor, :creator, :title, :description, :publisher, :administrative_unit, :curator, :date, :date_created, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url, :source]
  end
  it "should not delete member work when deleted" do
    @collection.members = [generic_work1, generic_work2]
    @collection.save
    @collection.destroy
    GenericWork.exists?(generic_work1.pid).should be_truthy
    GenericWork.exists?(generic_work2.pid).should be_truthy
  end

  describe "Collection by another name" do
    before (:all) do
      class OtherCollection < ActiveFedora::Base
        include Hydra::Collection
        include Hydra::Collections::Collectible
      end
      class Member < ActiveFedora::Base
        include Hydra::Collections::Collectible
      end
    end
    after(:all) do
      Object.send(:remove_const, :OtherCollection)
      Object.send(:remove_const, :Member)
    end

    it "have members that know about the collection" do
      collection = OtherCollection.new
      member = Member.create
      collection.members << member
      collection.save
      member.reload
      member.collections.should == [collection]
      collection.destroy
      member.destroy
    end
  end

end
