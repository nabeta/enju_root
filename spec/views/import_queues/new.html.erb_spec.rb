require 'spec_helper'

describe "/import_queues/new.html.erb" do
  include ImportQueuesHelper

  before(:each) do
    assigns[:import_queue] = stub_model(ImportQueue,
      :new_record? => true,
      :isbn => "value for isbn",
      :state => "value for state"
    )
  end

  it "renders new import_queue form" do
    render

    response.should have_tag("form[action=?][method=post]", import_queues_path) do
      with_tag("input#import_queue_isbn[name=?]", "import_queue[isbn]")
      with_tag("input#import_queue_state[name=?]", "import_queue[state]")
    end
  end
end
