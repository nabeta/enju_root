atom_feed(:url => formatted_purchase_requests_url(:atom)) do |feed|
  if @user
    feed.title t('purchase_request.user_purchase_request', :login_name => @user.login)
  else
    feed.title t('purchase_request.library_group_purchase_request', :library_group_name => @library_group.name)
  end
  feed.updated(@purchase_requests.first ? @purchase_requests.first.created_at : Time.zone.now)

  for purchase_request in @purchase_requests
    feed.entry(purchase_request) do |entry|
      entry.title(purchase_request.title)
      entry.author(purchase_request.author)
    end
  end
end
