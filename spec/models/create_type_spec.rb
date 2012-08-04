# == Schema Information
#
# Table name: create_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe CreateType do
  it 'should create create_type' do
    FactoryGirl.create(:create_type)
  end
end
