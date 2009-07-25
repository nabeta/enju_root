require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Expression do
  fixtures :expressions

  before(:each) do
    @valid_attributes = {
      :original_title => 'test'    
    }
  end

  it "should create a new instance given valid attributes" do
    Expression.create!(@valid_attributes)
  end
end
