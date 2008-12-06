## Helper for RESTful_Easy_Messages
module MessagesHelper
  
  # Generic menu
  def rezm_menu
    rezm_link_to_inbox + "|" + rezm_link_to_create_message + "|" + rezm_link_to_outbox + "|" + rezm_link_to_trash_bin
  end
  
  # Link to view the inbox
  def rezm_link_to_inbox
    link_to "Inbox", inbox_messages_path
  end
  
  # Link to compose a message
  def rezm_link_to_create_message
    link_to "Write", new_message_path
  end
  
  # Link to view the outbox
  def rezm_link_to_outbox
    link_to "Outbox", outbox_messages_path
  end
  
  # Link to view the trash bin
  def rezm_link_to_trash_bin
    link_to "Trash", trashbin_messages_path
  end
  
  # Dynamic label for the sender/receiver column in the messages.rhtml view
  def rezm_sender_or_receiver_label
    if params[:action] == "outbox"
      "Recipient"
    # Used for both inbox and trashbin
    else
      "Sender"
    end
  end
  
  # Checkbox for marking a message for deletion
  def rezm_delete_check_box(message)
    check_box_tag 'to_delete[]', message.id
  end
  
  # Link to view the message
  def rezm_link_to_message(message)
     link_to "#{h(rezm_subject_and_status(message))}", message_path(message)
  end
  
  # Dynamic data for the sender/receiver column in the messages.rhtml view
  def rezm_sender_or_receiver(message)
    if params[:action] == "outbox"
      rezm_to_user_link(message)
    # Used for both inbox and trashbin
    else
      rezm_from_user_link(message)
    end
  end
  
  # Pretty format for message sent date/time
  def rezm_sent_at(message)
    h(message.created_at.to_date.strftime('%m/%d/%Y') + " " + message.created_at.strftime('%I:%M %p').downcase)
  end
  
  # Pretty format for message.subject which appeads the status (Deleted/Unread)
  def rezm_subject_and_status(message)
    if message.receiver_deleted?
      message.subject + " (Deleted)" 
    elsif message.read_at.nil?
      message.subject + " (Unread)"  
    else 
      message.subject
    end
  end
  
  # Link to User for Message View
  def rezm_to_user_link(message)
    link_to message.receiver_name, user_path(message.receiver_name)
  end
  
  # Link from User for Message View
  def rezm_from_user_link(message)
    link_to message.sender_name, user_path(message.sender_name)
  end
  
  # Reply Button
  def rezm_button_to_reply(message)
    button_to "Reply", reply_message_path(message), :method => :get  
  end
  
  # Delete Button
  def rezm_button_to_delete(message)
    button_to "Delete", message_path(message), :confirm => "Are you sure?", :method => :delete  
  end
end
