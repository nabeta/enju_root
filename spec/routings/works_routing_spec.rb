require "spec_helper"

describe WorksController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/works" }.should route_to(:controller => "works", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/works/new" }.should route_to(:controller => "works", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/works/1" }.should route_to(:controller => "works", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/works/1/edit" }.should route_to(:controller => "works", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/works" }.should route_to(:controller => "works", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/works/1" }.should route_to(:controller => "works", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/works/1" }.should route_to(:controller => "works", :action => "destroy", :id => "1")
    end

  end
end
