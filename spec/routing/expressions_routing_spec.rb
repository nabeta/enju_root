require "spec_helper"

describe ExpressionsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/expressions" }.should route_to(:controller => "expressions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/expressions/new" }.should route_to(:controller => "expressions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/expressions/1" }.should route_to(:controller => "expressions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/expressions/1/edit" }.should route_to(:controller => "expressions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/expressions" }.should route_to(:controller => "expressions", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/expressions/1" }.should route_to(:controller => "expressions", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/expressions/1" }.should route_to(:controller => "expressions", :action => "destroy", :id => "1")
    end

  end
end
