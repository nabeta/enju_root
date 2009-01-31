atom_feed(:url => formatted_order_lists_url(:atom)) do |feed|
  feed.title t('order_list.library_group_order_list', :library_group.display_name => @library_group.display_name)
  end
  feed.updated(@order_lists.first ? @order_lists.first.created_at : Time.zone.now)

  for order_list in @order_lists
    feed.entry(order_list) do |entry|
      entry.title(order_list.title)
      entry.author(@library_group.display_name)
    end
  end
end
