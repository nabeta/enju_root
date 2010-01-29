require 'spec_helper'

describe ImportQueuesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/import_queues" }.should route_to(:controller => "import_queues", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/import_queues/new" }.should route_to(:controller => "import_queues", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/import_queues/1" }.should route_to(:controller => "import_queues", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/import_queues/1/edit" }.should route_to(:controller => "import_queues", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/import_queues" }.should route_to(:controller => "import_queues", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/import_queues/1" }.should route_to(:controller => "import_queues", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/import_queues/1" }.should route_to(:controller => "import_queues", :action => "destroy", :id => "1") 
    end
  end
end
