# == Schema Information
#
# Table name: search_engines
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  url              :string(255)      not null
#  base_url         :text             not null
#  http_method      :text             not null
#  query_param      :text             not null
#  additional_param :text
#  note             :text
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class SearchEngineTest < ActiveSupport::TestCase
  fixtures :search_engines
  # Replace this with your real tests.
end
