atom_feed(:url => formatted_expressions_url(:atom)) do |feed|
  feed.title("#{@library_group.display_name} search results")
  feed.updated(@expressions.first ? @expressions.first.created_at : Time.zone.now)

  for expression in @expressions
    feed.entry(expression) do |entry|
      entry.title(expression.original_title)

      expression.patrons.each do |patron|
        entry.author do |author|
          author.name(patron.full_name)
        end
      end
    end
  end
end
