# == Schema Information
#
# Table name: subjects
#
#  id                      :integer          not null, primary key
#  parent_id               :integer
#  use_term_id             :integer
#  term                    :string(255)
#  term_transcription      :text
#  subject_type_id         :integer          not null
#  scope_note              :text
#  note                    :text
#  required_role_id        :integer          default(1), not null
#  work_has_subjects_count :integer          default(0), not null
#  lock_version            :integer          default(0), not null
#  created_at              :datetime
#  updated_at              :datetime
#  deleted_at              :datetime
#

require 'test_helper'

class SubjectTest < ActiveSupport::TestCase
  fixtures :subjects

  # Replace this with your real tests.
  def test_should_get_term
    assert_not_nil subjects(:subject_00001).term
  end
end
