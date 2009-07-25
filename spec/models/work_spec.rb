require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Work do
  fixtures :works

  before(:each) do
    @valid_attributes = {
      :original_title => 'test'
    }
  end

  it "should create a new instance given valid attributes" do
    Work.create!(@valid_attributes)
  end
end
