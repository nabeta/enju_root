atom_feed(:url => formatted_works_url(:atom)) do |feed|
  feed.title("#{@library_group.name} search results")
  feed.updated(@works.first ? @works.first.created_at : Time.zone.now)

  for work in @works
    feed.entry(work) do |entry|
      entry.title(work.original_title)

      work.patrons.each do |patron|
        entry.author do |author|
          author.name(patron.full_name)
        end
      end
    end
  end
end
