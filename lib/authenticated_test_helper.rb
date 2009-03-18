module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    #@request.session[:user_id] = user ? users(user).id : nil
    record = users(user)
    session_class = session_class(record)
    @request.session[session_class.session_key] = record.send(record.class.acts_as_authentic_config[:persistence_token_field].to_s)
    @request.session["#{session_class.session_key}_id"] = record.id.to_s
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  
end
