module BookmarkedResourcesHelper
  def back_to_bookmarked_resource_index(user)
    #if session[:params][:bookmarked_resource]
    #  bookmarked_resources_path(:params => session[:params][:bookmarked_resource])
    if user
      user_bookmarked_resources_path(user.login)
    else
      bookmarked_resources_path
    end
  rescue
    bookmarked_resources_path
  end

end
