atom_feed(:url => formatted_corporate_bodies_url(:atom)) do |feed|
  feed.title t('corporate_body.library_group_corporate_body', :library_group_name => @library_group.display_name)
  feed.updated(@corporate_bodies.first ? @corporate_bodies.first.created_at : Time.zone.now)

  for corporate_body in @corporate_bodies
    feed.entry(corporate_body) do |entry|
      entry.title(corporate_body.full_name)

    end
  end
end
