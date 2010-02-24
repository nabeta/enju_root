class Notifier < ActionMailer::Base
  default_url_options[:host] = LIBRARY_WEB_HOSTNAME

  def message_notification(user)
    subject       I18n.t('message.new_message_from_library', :library => LibraryGroup.site_config.display_name.localize)
    #from          "#{LibraryGroup.site_config.display_name.localize} <#{LibraryGroup.site_config.email}>"
    from          "#{LibraryGroup.site_config.email}"
    recipients    user.email
    sent_on       Time.zone.now
    body          :user => user
  end

  def manifestation_info(user, manifestation)
    subject       "#{manifestation.original_title} : #{LibraryGroup.site_config.display_name.localize}"
    #from          "#{LibraryGroup.site_config.display_name.localize} <#{LibraryGroup.site_config.email}>"
    from          "#{LibraryGroup.site_config.email}"
    recipients    user.email
    sent_on       Time.zone.now
    body          :user => user, :manifestation => manifestation
  end

  def activation_instructions(user)
    subject       "Activation Instructions"
    from          "#{LibraryGroup.site_config.email}"
    recipients    user.email
    sent_on       Time.zone.now
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    subject       "Activation Complete"
    from          "#{LibraryGroup.site_config.email}"
    recipients    user.email
    sent_on       Time.zone.now
    body          :root_url => root_url
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "#{LibraryGroup.site_config.email}"
    recipients    user.email
    sent_on       Time.zone.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

end
