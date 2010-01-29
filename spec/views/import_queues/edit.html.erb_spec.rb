require 'spec_helper'

describe "/import_queues/edit.html.erb" do
  include ImportQueuesHelper

  before(:each) do
    assigns[:import_queue] = @import_queue = stub_model(ImportQueue,
      :new_record? => false,
      :isbn => "value for isbn",
      :state => "value for state"
    )
  end

  it "renders the edit import_queue form" do
    render

    response.should have_tag("form[action=#{import_queue_path(@import_queue)}][method=post]") do
      with_tag('input#import_queue_isbn[name=?]', "import_queue[isbn]")
      with_tag('input#import_queue_state[name=?]', "import_queue[state]")
    end
  end
end
