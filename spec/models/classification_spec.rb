require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Classification do
  fixtures :classifications

  before(:each) do
    @valid_attributes = {
      :classification_type_id => 1, :category => 'test'
    }
  end

  it "should create a new instance given valid attributes" do
    Classification.create!(@valid_attributes)
  end
end
