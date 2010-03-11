require 'spec_helper'

describe CalendarController do
  fixtures :events, :event_categories, :libraries

  describe "GET index" do
    it "assigns events as @event_strips" do
      get :index
      assigns[:event_strips].should_not be_nil
    end
  end

end
