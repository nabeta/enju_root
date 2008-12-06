require File.dirname(__FILE__) + '/../spec_helper'


describe ActsAsSolr::IndexedAtStamp do
  before(:each) do
    @it = Book.new :name => 'organisation'
    @it.stub!(:valid?).and_return(true)
    @it.stub!(:solr_save_without_indexed_at_stamp)
    @it.save!
  end
  
  describe "(when saving solr index)" do
    it "should update last indexed at if column exists" do
      @it.should_receive(:stamp_last_indexed_at_if_column_exists)
      # Directly calling 'with....' method, as solr_save is stubbed out for all specs
      @it.solr_save_with_indexed_at_stamp
    end
    
    it "should return result of standard solr_save" do
      @it.stub!(:solr_save_without_indexed_at_stamp).and_return(:a_value)
      @it.stub!(:stamp_last_indexed_at_if_column_exists)
      @it.solr_save_with_indexed_at_stamp.should == :a_value
    end
  end
  
  describe '#stamp_last_indexed_at_if_column_exists' do
    it "should update indexed at if column exists" do
      Time.freeze do
        @it.solr_save_with_indexed_at_stamp
        @it.reload
        @it.indexed_at.to_s.should == Time.now.to_s
      end
    end
    
    it "should do nothing if column does not exist" do
      Time.freeze do
        @it.stub!(:column_for_attribute).with('indexed_at').and_return(nil)
        @it.solr_save_with_indexed_at_stamp
        @it.reload
        @it.indexed_at.should == nil
      end
    end
  end
end
