atom_feed(:url => formatted_checkouts_url(:atom)) do |feed|
  if @user
    feed.title t('checkout.user_checkout', :login_name => @user.login)
  else
    feed.title t('checkout.library_group_checkout', :library_group.display_name => @library_group.display_name)
  end
  feed.updated(@checkouts.first ? @checkouts.first.created_at : Time.zone.now)

  for checkout in @checkouts
    feed.entry(checkout) do |entry|
      entry.title(checkout.item.manifestation.original_title)
    end
  end
end
