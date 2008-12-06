atom_feed(:url => formatted_patrons_url(:atom)) do |feed|
  feed.title("#{@library_group.name} search results")
  feed.updated(@patrons.first ? @patrons.first.created_at : Time.zone.now)

  for patron in @patrons
    feed.entry(patron) do |entry|
      entry.title(patron.full_name)

    end
  end
end
