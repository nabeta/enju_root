require 'spec_helper'

describe "/import_requests/edit.html.erb" do
  include ImportRequestsHelper

  before(:each) do
    assigns[:import_request] = @import_request = stub_model(ImportRequest,
      :new_record? => false,
      :isbn => "value for isbn",
      :state => "value for state"
    )
  end

  it "renders the edit import_request form" do
    render

    response.should have_tag("form[action=#{import_request_path(@import_request)}][method=post]") do
      with_tag('input#import_request_isbn[name=?]', "import_request[isbn]")
      with_tag('input#import_request_state[name=?]', "import_request[state]")
    end
  end
end
