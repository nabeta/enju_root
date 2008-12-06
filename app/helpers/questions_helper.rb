module QuestionsHelper
  def back_to_question_index
    if session[:params][:question]
      user_questions_path(:params => session[:params][:question])
    else
      raise
    end
  rescue
    questions_path
  end
end
