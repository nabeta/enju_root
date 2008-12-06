require File.dirname(__FILE__) + '/spec_helper'

describe DateTimeTextFieldHelpers::FormHelpers do

  it "should include date_text_field method" do
    ActionView::Helpers::FormBuilder.instance_methods.should include('date_text_field')
  end
    
  it "should include time_text_field method" do
    ActionView::Helpers::FormBuilder.instance_methods.should include('time_text_field')
  end
  
  it "should include datetime_text_field method" do
    ActionView::Helpers::FormBuilder.instance_methods.should include('datetime_text_field')
  end    

end 
