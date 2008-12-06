require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  fixtures :questions

  # Replace this with your real tests.
  def test_should_get_refkyo_search
    results =Question.refkyo_search('Yahoo')
    assert results[:total_count] > 0
    assert_not_nil results[:resources]
  end
end
