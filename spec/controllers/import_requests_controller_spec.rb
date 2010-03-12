require 'spec_helper'

describe ImportRequestsController do
  fixtures :library_groups

  def mock_import_request(stubs={})
    @mock_import_request ||= mock_model(ImportRequest, stubs)
  end

  describe "GET index" do
    it "assigns all import_requests as @import_requests" do
      ImportRequest.stub(:find).with(:all).and_return([mock_import_request])
      get :index
      assigns[:import_requests].should == [mock_import_request]
    end
  end

  describe "GET show" do
    it "assigns the requested import_request as @import_request" do
      ImportRequest.stub(:find).with("37").and_return(mock_import_request)
      get :show, :id => "37"
      assigns[:import_request].should equal(mock_import_request)
    end
  end

  describe "GET new" do
    it "assigns a new import_request as @import_request" do
      ImportRequest.stub(:new).and_return(mock_import_request)
      get :new
      assigns[:import_request].should equal(mock_import_request)
    end
  end

  describe "GET edit" do
    it "assigns the requested import_request as @import_request" do
      ImportRequest.stub(:find).with("37").and_return(mock_import_request)
      get :edit, :id => "37"
      assigns[:import_request].should equal(mock_import_request)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created import_request as @import_request" do
        ImportRequest.stub(:new).with({'these' => 'params'}).and_return(mock_import_request(:save => true))
        post :create, :import_request => {:these => 'params'}
        assigns[:import_request].should equal(mock_import_request)
      end

      it "redirects to the created import_request" do
        ImportRequest.stub(:new).and_return(mock_import_request(:save => true))
        post :create, :import_request => {}
        response.should redirect_to(import_request_url(mock_import_request))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved import_request as @import_request" do
        ImportRequest.stub(:new).with({'these' => 'params'}).and_return(mock_import_request(:save => false))
        post :create, :import_request => {:these => 'params'}
        assigns[:import_request].should equal(mock_import_request)
      end

      it "re-renders the 'new' template" do
        ImportRequest.stub(:new).and_return(mock_import_request(:save => false))
        post :create, :import_request => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested import_request" do
        ImportRequest.should_receive(:find).with("37").and_return(mock_import_request)
        mock_import_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :import_request => {:these => 'params'}
      end

      it "assigns the requested import_request as @import_request" do
        ImportRequest.stub(:find).and_return(mock_import_request(:update_attributes => true))
        put :update, :id => "1"
        assigns[:import_request].should equal(mock_import_request)
      end

      it "redirects to the import_request" do
        ImportRequest.stub(:find).and_return(mock_import_request(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(import_request_url(mock_import_request))
      end
    end

    describe "with invalid params" do
      it "updates the requested import_request" do
        ImportRequest.should_receive(:find).with("37").and_return(mock_import_request)
        mock_import_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :import_request => {:these => 'params'}
      end

      it "assigns the import_request as @import_request" do
        ImportRequest.stub(:find).and_return(mock_import_request(:update_attributes => false))
        put :update, :id => "1"
        assigns[:import_request].should equal(mock_import_request)
      end

      it "re-renders the 'edit' template" do
        ImportRequest.stub(:find).and_return(mock_import_request(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested import_request" do
      ImportRequest.should_receive(:find).with("37").and_return(mock_import_request)
      mock_import_request.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the import_requests list" do
      ImportRequest.stub(:find).and_return(mock_import_request(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(import_requests_url)
    end
  end

end
