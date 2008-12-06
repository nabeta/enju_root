module RestfulEasyMessagesControllerSystem
  protected
  
  # This method provides an abstraction layer to the REZM controller for the
  # "current", logged-in user in case you are not using Restful_Authentication.
  def rezm_user
    # Provide your version of current_user here if not using Restful_authentication
    current_user
  end
  
  # This method provides an abstraction layer to the REZM controller for 
  # requiring a user to be loggefd in if you are not using Restful_Authentication.
  def rezm_login_required
    # Provide your version of login_required here if not using Restful_authentication
    login_required
  end
  
  # Inclusion hook to make #rezm_user
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :rezm_user
  end
end