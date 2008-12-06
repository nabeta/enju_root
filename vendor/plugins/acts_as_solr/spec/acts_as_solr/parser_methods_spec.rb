require File.dirname(__FILE__) + '/../spec_helper'

describe ActsAsSolr::ParserMethods do
  describe "#map_query_to_fields" do
    before(:each) do
      Book.should respond_to(:configuration) # safe stub!
      Book.stub!(:configuration).and_return(
        :solr_fields => [
          [:id,     {:type => :integer}],
          [:title,  {:type => :sort}],
          [:title,  {:type => :string}],
          ["title", {:type => :text}], # chuck in a string
          [:created_at, {:type => :date}],
          [:score,  {:type => :text}], # chuck this into the mix
        ])
    end
    
    def map(query)
      Book.send(:map_query_to_fields, query)
    end
    
    it "should map each supplied field to its indexed equivalent" do
      rtn = map("a normal keyword AND title:(something titleish) AND created_at:(200707010000)")
      rtn.should == "a normal keyword AND title_s:(something titleish) AND created_at_d:(200707010000)"
    end
 
    it "should favour :string or :text fields" do
      rtn = map("title:(ish)")
      rtn.should == "title_s:(ish)"
    end
    
    it "should eliminate whitespace around the ':'" do
      rtn = map(" some keyword stuff AND   title    :  a clause  AND   title     :  (another)  ")
      rtn.should == " some keyword stuff AND   title_s:a clause  AND   title_s:(another)  "
    end
    
    it "should not alter instances of field names elsewhere in the query" do
      rtn = map("    title   title   AND title OR title : title title AND title:( title title) title")
      rtn.should == "    title   title   AND title OR title_s:title title AND title_s:( title title) title"
    end
    
    it "should work with field_names featuring an '_'" do
      rtn = map("created_at : (200707010000)")
      rtn.should == "created_at_d:(200707010000)"
    end
  end
  
  describe "#map_order_to_fields" do
    before(:each) do
      Book.should respond_to(:configuration) # safe stub!
      Book.stub!(:configuration).and_return(
        :solr_fields => [
          [:id,     {:type => :integer}],
          [:title,  {:type => :string}],
          ["title", {:type => :text}], # chuck in a string
          [:title,  {:type => :sort}],
          [:created_at, {:type => :date}],
          [:score,  {:type => :text}], # chuck this into the mix
        ])
    end
    
    it "should map each supplied field to its indexed equivalent" do
      rtn = Book.send(:map_order_to_fields, "id asc, created_at desc")
      rtn.should == "id_i asc,created_at_d desc"
    end
    
    it "should leave score intact" do
      rtn = Book.send(:map_order_to_fields, "score asc")
      rtn.should == "score asc"
    end
    
    it "should favour :sort fields" do
      rtn = Book.send(:map_order_to_fields, "title desc")
      rtn.should == "title_sort desc"
    end
    
    it "should lowercase any provided directions" do
      rtn = Book.send(:map_order_to_fields, "one_way ASC, other_way DESC")
      rtn.should == "one_way asc,other_way desc"
    end
    
    it "should append an 'asc' to any non directed field" do
      rtn = Book.send(:map_order_to_fields, "missing , the, direction")
      rtn.should == "missing asc,the asc,direction asc"
    end
    
    it "should clear excess white space" do
      rtn = Book.send(:map_order_to_fields, " something    asc  ,  too_open    ")
      rtn.should == "something asc,too_open asc"
    end
  end
    
  describe "#field_name_to_solr_field" do
    describe "(with stubs)" do
      before(:each) do
        Book.should respond_to(:configuration) # safe stub!
        Book.stub!(:configuration).and_return(
          :solr_fields => [
            [:id,     {:type => :integer}],
            [:title,  {:type => :string}],
            ["title", {:type => :text}], # chuck in a string
            [:title,  {:type => :sort}],
            [:created_at, {:type => :date}],
          ])
      end
    
      it "should return a normalised field" do
        rtn = Book.send(:field_name_to_solr_field, "title")
        rtn.should == [:title, {:type => :string}]
      end
      
      it "should accept a string field_name" do
        rtn = Book.send(:field_name_to_solr_field, "id")
        rtn.should == [:id, {:type => :integer}]
      end
      
      it "should accept a symbol field_name" do
        rtn = Book.send(:field_name_to_solr_field, :id)
        rtn.should == [:id, {:type => :integer}]
      end
    
      it "should return the first matching :solr_fields entry by default" do
        rtn = Book.send(:field_name_to_solr_field, "title")
        rtn.should == [:title, {:type => :string}]
      end
      
      it "should match a favoured_type first" do
        rtn = Book.send(:field_name_to_solr_field, "title", :sort)
        rtn.should == [:title, {:type => :sort}]
      end
      
      it "should ingore a nil favoured_type" do
        rtn = Book.send(:field_name_to_solr_field, "title", nil)
        rtn.should == [:title, {:type => :string}]
      end
      
      it "should match multiple favoured types" do
        rtn = Book.send(:field_name_to_solr_field, "title", [:sort, :date])
        rtn.should == [:title, {:type => :sort}]
      end
      
      it "should ignore an absent favoured type" do
        rtn = Book.send(:field_name_to_solr_field, "title", :not_here)
        rtn.should == [:title, {:type => :string}]
      end
      
      it "should ignore multiple absent favoured types" do
        rtn = Book.send(:field_name_to_solr_field, "title", [:date, :integer, :are, :unmatched])
        rtn.should == [:title, {:type => :string}]
      end
      
      it "should return nil for no match" do
        Book.send(:field_name_to_solr_field, "no_field").should == nil
      end
    end
    
    describe "(without stubs)" do
      it "should return a normalised field" do
        rtn = Book.send(:field_name_to_solr_field, "name")
        rtn.should == [:name, {:type => :text}]
      end
    end
  end
  
  describe "#solr_field_to_lucene_field" do  
    it "should return a string" do
      rtn = Book.send(:solr_field_to_lucene_field, [:title, {:type => :string}])
      rtn.should == "title_s"
    end
    
    [[:sort, "sort"], [:string, "s"], [:text, "t"]].each do |field_type, suffix|
      it "should handle #{field_type.inspect} fields" do
        rtn = Book.send(:solr_field_to_lucene_field, [:fieldy, {:type => field_type}])
        rtn.should == "fieldy_#{suffix}"
      end
    end
  end
  
  describe "#field_name_to_lucene_field" do
    it "should conjoin fn-sf and sf-lf" do
      Book.should_receive(:field_name_to_solr_field).with("some", :input).and_return("join")
      Book.should_receive(:solr_field_to_lucene_field).with("join").and_return("together")
      
      Book.send(:field_name_to_lucene_field, "some", :input).should == "together"
    end
    
    it "should default to prefering :string and :text" do
      Book.should_receive(:field_name_to_solr_field).with("something", [:string, :text]).and_return([:title, {:type => :string}])
      
      Book.send(:field_name_to_lucene_field, "something").should == "title_s"
    end
    
    it "should return just the field name if there is no matching solr_field" do
      Book.should_receive(:field_name_to_solr_field).with("some", :input).and_return(nil)
      Book.should_receive(:solr_field_to_lucene_field).exactly(0).times
      
      Book.send(:field_name_to_lucene_field, "some", :input).should == "some"
    end
  end
end