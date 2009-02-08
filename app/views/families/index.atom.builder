atom_feed(:url => formatted_families_url(:atom)) do |feed|
  feed.title t('family.library_group_family', :library_group_name => @library_group.display_name)
  feed.updated(@families.first ? @families.first.created_at : Time.zone.now)

  for family in @families
    feed.entry(family) do |entry|
      entry.title(family.full_name)

    end
  end
end
