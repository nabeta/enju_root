require 'spec_helper'

describe "/import_queues/index.html.erb" do
  include ImportQueuesHelper

  before(:each) do
    assigns[:import_queues] = [
      stub_model(ImportQueue,
        :isbn => "value for isbn",
        :state => "value for state"
      ),
      stub_model(ImportQueue,
        :isbn => "value for isbn",
        :state => "value for state"
      )
    ]
  end

  it "renders a list of import_queues" do
    render
    response.should have_tag("tr>td", "value for isbn".to_s, 2)
    response.should have_tag("tr>td", "value for state".to_s, 2)
  end
end
