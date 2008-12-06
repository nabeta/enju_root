require File.dirname(__FILE__) + '/spec_helper'

class SomeView
  include WillPaginateActsAsSolr::ViewHelpers
end

describe SomeModel do
  
  it "should respond to paginate_by_solr" do
    SomeModel.should respond_to(:paginate_by_solr)
  end
  
  it "should respond to find_by_solr" do
    SomeModel.should respond_to(:find_by_solr)
  end

  describe "paginate_by_solr" do
    before(:each) do
      @total_hits = 56
      @docs = Array.new(10){ SomeModel.new } # we dont have rspec-rails
      @find_by_solr = stub("a find_by_solr return", :total_hits => @total_hits, :docs => @docs)
      SomeModel.stub!(:find_by_solr).and_return(@find_by_solr)
    end
    
    def do_paginate
      SomeModel.paginate_by_solr("*", {:page => 2, :per_page => 20})
    end
    
    it "should return a WillPaginate::Collection" do
      do_paginate.should be_a_kind_of(WillPaginate::Collection)
    end
    
    it "should set the :total_entries" do
      do_paginate.total_entries.should == @find_by_solr.total_hits
    end
    
    it "should match the @docs (even though the collection is a superclass)" do
      do_paginate.should == @docs
    end
  end
  
  describe "will_paginate_header" do
    before(:each) do
      @array = ('a'..'z').to_a
    end
    
    def do_paginate(options={:page => 2, :per_page => 5})
      @array.paginate(options)
    end
    
    def do_view(*args)
      SomeView.new.will_paginate_header(*args)
    end
    
    it "should verbalise the range of entries" do
      collection = do_paginate(:page => 2, :per_page => 5)
      do_view(collection).should == %{Showing <b>6</b> to <b>10</b> of <b>26</b> strings}
    end
    
    it "should verbalise the last page of entries" do
      collection = do_paginate(:page => 7, :per_page => 4)
      do_view(collection).should == %{Showing <b>25</b> to <b>26</b> of <b>26</b> strings}
    end

    it "should verbalise a single page the same as any other" do
      collection = do_paginate(:page => 1, :per_page => 99999)
      do_view(collection).should == %{Showing <b>1</b> to <b>26</b> of <b>26</b> strings}
    end
    
    it "should use a provided :entry_name" do
      collection = do_paginate(:page => 1, :per_page => 99999)
      do_view(collection, :entry_name => "Wurble").should == %{Showing <b>1</b> to <b>26</b> of <b>26</b> Wurbles}
    end
    
    it "should verbalise an empty pagination" do
      collection = [].paginate(:page => 1, :per_page => 20)
      do_view(collection).should == "Showing <b>1</b> to <b>0</b> of <b>0</b> results"
    end
 
  end

end