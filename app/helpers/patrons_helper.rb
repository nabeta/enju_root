module PatronsHelper
  def back_to_patron_index
    case
    when session[:params][:patron]
      patrons_path(:params => session[:params][:patron])
    when session[:params][:resource]
      patrons_path(:params => session[:params][:resource])
    when session[:params][:manifestation]
      patrons_path(:params => session[:params][:manifestation])
    when session[:params][:expression]
      patrons_path(:params => session[:params][:expression])
    when session[:params][:work]
      patrons_path(:params => session[:params][:work])
    else
      patrons_path
    end
  rescue
    patrons_path
  end
end
