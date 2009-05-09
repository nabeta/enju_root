atom_feed(:url => expressions_url(:format => :atom)) do |feed|
  feed.title t('expression.library_group_expression', :library_group_name => @library_group.display_name.localize)
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
