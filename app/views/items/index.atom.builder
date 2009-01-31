atom_feed(:url => formatted_items_url(:atom)) do |feed|
  feed.title t('item.library_group_item', :library_group_name => @library_group.display_name)
  feed.updated(@items.first ? @items.first.created_at : Time.zone.now)

  for item in @items
    feed.entry(item) do |entry|
      entry.title(item.manifestation.original_title)

    end
  end
end
