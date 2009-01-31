atom_feed(:url => formatted_manifestations_url(:atom)) do |feed|
  feed.title("#{@library_group.display_name} search results")
  feed.updated(@manifestations.first ? @manifestations.first.created_at : Time.zone.now)

  for manifestation in @manifestations
    feed.entry(manifestation) do |entry|
      entry.title(manifestation.original_title)
      entry.content(manifestation.tag_list, :type => 'html')

      manifestation.authors.each do |patron|
        entry.author do |author|
          author.name(patron.full_name)
        end
      end
    end
  end
end
