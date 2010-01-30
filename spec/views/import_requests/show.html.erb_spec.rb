require 'spec_helper'

describe "/import_requests/show.html.erb" do
  include ImportRequestsHelper
  before(:each) do
    assigns[:import_request] = @import_request = stub_model(ImportRequest,
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
