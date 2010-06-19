atom_feed(:url => items_url(:format => :atom)) do |feed|
  feed.title t('item.library_group_item', :library_group_name => @library_group.display_name.local)
  feed.updated(@items.first ? @items.first.created_at : Time.zone.now)

  @items.each do |item|
    feed.entry(item) do |entry|
      entry.title(item.manifestation.original_title)

    end
  end
end
