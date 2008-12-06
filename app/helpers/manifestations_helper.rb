module ManifestationsHelper
  def back_to_manifestation_index
    if session[:params][:manifestation]
      manifestations_path(:params => session[:params][:manifestation])
    elsif session[:params][:bookmarked_resource]
      if current_user
        user_bookmarked_resources_path(:params => session[:params][:bookmarked_resource])
      else
        bookmarked_resources_path(:params => session[:params][:bookmarked_resource])
      end
    else
      manifestations_path
    end
  rescue
    manifestations_path
  end

  def call_number_label(item)
    unless item.call_number.blank?
      unless item.shelf.web_shelf?
        # TODO 請求記号の区切り文字
        numbers = item.call_number.split(item.shelf.library.call_number_delimiter)
        @call_numbers = []
        numbers.each do |number|
          @call_numbers << h(number.to_s)
        end
        render :partial => 'call_number', :locals => {:item => item}
      end
    end
  end

  def language_list(languages)
    list = []
    languages.each do |language|
      list << h(language.display_name)
    end
    list.join("; ")
  end

  def paginate_id_link(manifestation)
    links = []
    if session[:manifestation_ids].is_a?(Array)
      current_seq = session[:manifestation_ids].index(manifestation.id)
      if current_seq
        unless manifestation.id == session[:manifestation_ids].first
          links << link_to(('Previous'), manifestation_path(session[:manifestation_ids][current_seq - 1]))
        end
        unless manifestation.id == session[:manifestation_ids].last
          links << link_to(('Next'), manifestation_path(session[:manifestation_ids][current_seq + 1]))
        end
      end
    end
    links.join(" ")
  end
end
