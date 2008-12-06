atom_feed do |feed|
  feed.title "#{@rezm_user.login}'s Inbox"
  feed.updated @messages.first.created_at
  
  for message in @messages
    feed.entry(message, :url => user_message_url(rezm_user.login, message)) do |entry|
     entry.title   message.subject
      entry.content message.body, :type => 'html'
      
      entry.author do |author|
        author.name message.sender.login
      end
    end
  end
end
