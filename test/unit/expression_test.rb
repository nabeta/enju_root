require 'test_helper'

class ExpressionTest < ActiveSupport::TestCase
  fixtures :expressions, :manifestations, :embodies

  def test_title
    assert expressions(:expression_00001).title
  end
  
  def test_titles
    assert expressions(:expression_00001).titles
  end
end
# == Schema Information
#
# Table name: expressions
#
#  id                          :integer         not null, primary key
#  original_title              :text            not null
#  title_transcription         :text
#  title_alternative           :text
#  summarization               :text
#  context                     :text
#  language_id                 :integer         default(1), not null
#  content_type_id             :integer         default(1), not null
#  note                        :text
#  realizes_count              :integer         default(0), not null
#  embodies_count              :integer         default(0), not null
#  resource_has_subjects_count :integer         default(0), not null
#  lock_version                :integer         default(0), not null
#  created_at                  :datetime        not null
#  updated_at                  :datetime        not null
#  deleted_at                  :datetime
#  required_role_id            :integer         default(1), not null
#  feed_url                    :string(255)
#  state                       :string(255)
#  required_score              :integer         default(0), not null
#  date_of_expression          :datetime
#  identifier                  :string(255)
#

