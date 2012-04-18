require 'test_helper'

class SearchHistoryTest < ActiveSupport::TestCase
  fixtures :search_histories

  # Replace this with your real tests.
end
# == Schema Information
#
# Table name: search_histories
#
#  id                             :integer         not null, primary key
#  user_id                        :integer
#  operation                      :string(255)     default("searchRetrieve")
#  sru_version                    :float           default(1.2)
#  query                          :string(255)
#  start_record                   :integer
#  maximum_records                :integer
#  record_packing                 :string(255)
#  record_schema                  :string(255)
#  result_set_ttl                 :integer
#  stylesheet                     :string(255)
#  extra_request_data             :string(255)
#  number_of_records              :integer         default(0)
#  result_set_id                  :string(255)
#  result_set_idle_time           :integer
#  records                        :text
#  next_record_position           :integer
#  diagnostics                    :text
#  extra_response_data            :text
#  echoed_search_retrieve_request :text
#  created_at                     :datetime        not null
#  updated_at                     :datetime        not null
#

