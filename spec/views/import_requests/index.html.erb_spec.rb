require 'spec_helper'

describe "/import_requests/index.html.erb" do
  include ImportRequestsHelper

  before(:each) do
    assigns[:import_requests] = [
      stub_model(ImportRequest,
        :isbn => "value for isbn",
        :state => "value for state"
      ),
      stub_model(ImportRequest,
        :isbn => "value for isbn",
        :state => "value for state"
      )
    ]
  end

  it "renders a list of import_requests" do
    render
    response.should have_tag("tr>td", "value for isbn".to_s, 2)
    response.should have_tag("tr>td", "value for state".to_s, 2)
  end
end
