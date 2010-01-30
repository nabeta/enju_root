require 'spec_helper'

describe ImportRequest do
  before(:each) do
    @valid_attributes = {
      :isbn => "value for isbn",
      :state => "value for state"
    }
  end

  it "should create a new instance given valid attributes" do
    ImportRequest.create!(@valid_attributes)
  end
end
