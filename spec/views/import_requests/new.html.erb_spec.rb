require 'spec_helper'

describe "/import_requests/new.html.erb" do
  include ImportRequestsHelper

  before(:each) do
    assigns[:import_request] = stub_model(ImportRequest,
      :new_record? => true,
      :isbn => "value for isbn",
      :state => "value for state"
    )
  end

  it "renders new import_request form" do
    render

    response.should have_tag("form[action=?][method=post]", import_requests_path) do
      with_tag("input#import_request_isbn[name=?]", "import_request[isbn]")
      with_tag("input#import_request_state[name=?]", "import_request[state]")
    end
  end
end
