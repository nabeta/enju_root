module TagsHelper
  def back_to_tag_index
    if session[:params][:tag]
      tags_path(:params => session[:params][:tag])
    else
      tags_path
    end
  rescue
    tags_path
  end
end
