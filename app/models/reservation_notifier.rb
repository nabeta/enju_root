class ReservationNotifier < ActionMailer::Base

  def accepted(user, manifestation)
    library_group = LibraryGroup.site_config
    subject     ('Reservation accepted')
    body        :patron => user.patron, :manifestation => manifestation, :library_group_name => library_group.name
    recipients  user.email
    from        library_group.email
    headers     {}
  end

  def reserved(user, manifestation, sent_at = Time.zone.now)
    library_group = LibraryGroup.site_config
    subject     ('Reserved resource is now available')
    body        :patron => user.patron, :manifestation => manifestation, :library_name => library_group.name
    recipients  user.email
    from        library_group.email
    sent_on     sent_at
    headers     {}
  end

  def expired(user, manifestation, sent_at = Time.zone.now)
    library_group = LibraryGroup.site_config
    subject     ('Reservation expired')
    body        :patron => user.patron, :manifestation => manifestation, :library_name => library_group.name
    recipients  user.email
    from        library_group.email
    sent_on     sent_at
    headers     {}
  end
end
