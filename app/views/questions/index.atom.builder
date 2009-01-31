atom_feed(:url => formatted_questions_url(:atom)) do |feed|
  if @user
    feed.title t('question.user_question', :login_name => @user.login)
  else
    feed.title t('question.library_group_question', :library_group_name => @library_group.display_name)
  end
  feed.updated(@questions.first ? @questions.first.created_at : Time.zone.now)

  for question in @questions
    feed.entry(question) do |entry|
      entry.title(truncate(question.body))
      entry.author(question.user.login)
      entry.content(question.body)
    end
  end
end
