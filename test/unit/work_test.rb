# == Schema Information
#
# Table name: works
#
#  id                          :integer          not null, primary key
#  original_title              :text             not null
#  title_transcription         :text
#  title_alternative           :text
#  context                     :text
#  form_of_work_id             :integer          default(1), not null
#  note                        :text
#  creates_count               :integer          default(0), not null
#  reifies_count               :integer          default(0), not null
#  resource_has_subjects_count :integer          default(0), not null
#  lock_version                :integer          default(0), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  required_role_id            :integer          default(1), not null
#  state                       :string(255)
#  required_score              :integer          default(0), not null
#  medium_of_performance_id    :integer          default(1), not null
#  parent_of_series            :boolean          default(FALSE), not null
#  series_statement_id         :integer
#  work_identifier             :string(255)
#

require 'test_helper'

class WorkTest < ActiveSupport::TestCase
  fixtures :works

  def test_title
    assert works(:work_00001).title
  end

  def test_titles
    assert works(:work_00001).titles
  end

end
