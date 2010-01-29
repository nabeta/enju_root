require 'spec_helper'

describe ImportQueuesController do

  def mock_import_queue(stubs={})
    @mock_import_queue ||= mock_model(ImportQueue, stubs)
  end

  describe "GET index" do
    it "assigns all import_queues as @import_queues" do
      ImportQueue.stub(:find).with(:all).and_return([mock_import_queue])
      get :index
      assigns[:import_queues].should == [mock_import_queue]
    end
  end

  describe "GET show" do
    it "assigns the requested import_queue as @import_queue" do
      ImportQueue.stub(:find).with("37").and_return(mock_import_queue)
      get :show, :id => "37"
      assigns[:import_queue].should equal(mock_import_queue)
    end
  end

  describe "GET new" do
    it "assigns a new import_queue as @import_queue" do
      ImportQueue.stub(:new).and_return(mock_import_queue)
      get :new
      assigns[:import_queue].should equal(mock_import_queue)
    end
  end

  describe "GET edit" do
    it "assigns the requested import_queue as @import_queue" do
      ImportQueue.stub(:find).with("37").and_return(mock_import_queue)
      get :edit, :id => "37"
      assigns[:import_queue].should equal(mock_import_queue)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created import_queue as @import_queue" do
        ImportQueue.stub(:new).with({'these' => 'params'}).and_return(mock_import_queue(:save => true))
        post :create, :import_queue => {:these => 'params'}
        assigns[:import_queue].should equal(mock_import_queue)
      end

      it "redirects to the created import_queue" do
        ImportQueue.stub(:new).and_return(mock_import_queue(:save => true))
        post :create, :import_queue => {}
        response.should redirect_to(import_queue_url(mock_import_queue))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved import_queue as @import_queue" do
        ImportQueue.stub(:new).with({'these' => 'params'}).and_return(mock_import_queue(:save => false))
        post :create, :import_queue => {:these => 'params'}
        assigns[:import_queue].should equal(mock_import_queue)
      end

      it "re-renders the 'new' template" do
        ImportQueue.stub(:new).and_return(mock_import_queue(:save => false))
        post :create, :import_queue => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested import_queue" do
        ImportQueue.should_receive(:find).with("37").and_return(mock_import_queue)
        mock_import_queue.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :import_queue => {:these => 'params'}
      end

      it "assigns the requested import_queue as @import_queue" do
        ImportQueue.stub(:find).and_return(mock_import_queue(:update_attributes => true))
        put :update, :id => "1"
        assigns[:import_queue].should equal(mock_import_queue)
      end

      it "redirects to the import_queue" do
        ImportQueue.stub(:find).and_return(mock_import_queue(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(import_queue_url(mock_import_queue))
      end
    end

    describe "with invalid params" do
      it "updates the requested import_queue" do
        ImportQueue.should_receive(:find).with("37").and_return(mock_import_queue)
        mock_import_queue.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :import_queue => {:these => 'params'}
      end

      it "assigns the import_queue as @import_queue" do
        ImportQueue.stub(:find).and_return(mock_import_queue(:update_attributes => false))
        put :update, :id => "1"
        assigns[:import_queue].should equal(mock_import_queue)
      end

      it "re-renders the 'edit' template" do
        ImportQueue.stub(:find).and_return(mock_import_queue(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested import_queue" do
      ImportQueue.should_receive(:find).with("37").and_return(mock_import_queue)
      mock_import_queue.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the import_queues list" do
      ImportQueue.stub(:find).and_return(mock_import_queue(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(import_queues_url)
    end
  end

end
