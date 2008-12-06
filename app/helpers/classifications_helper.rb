module ClassificationsHelper
  def back_to_classification_index
    classifications_path(:params => session[:params][:classification])
  rescue
    classifications_path
  end
end
