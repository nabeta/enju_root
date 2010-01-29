require 'spec_helper'

describe "/import_queues/show.html.erb" do
  include ImportQueuesHelper
  before(:each) do
    assigns[:import_queue] = @import_queue = stub_model(ImportQueue,
      :isbn => "value for isbn",
      :state => "value for state"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ isbn/)
    response.should have_text(/value\ for\ state/)
  end
end
