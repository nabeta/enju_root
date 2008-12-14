# Restful_Easy_Messages
module ProtonMicro
  module RestfulEasyMessages
    module Messages

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def restful_easy_messages(options = {})
        
          has_many :messages_as_sender,    
                   :class_name => "Message", 
                   :foreign_key => "sender_id"
          
          has_many :messages_as_receiver,  
                   :class_name => "Message", 
                   :foreign_key => "receiver_id"
          
          has_many :users_who_messaged_me, 
                   :through => :messages_as_receiver, 
                   :source => :sender,
                   :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"

          has_many :users_whom_i_have_messaged,
                   :through => :messages_as_sender,
                   :source => :receiver,
                   :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"

          has_many :unread_messages,
                   :through => :messages_as_receiver,
                   :source => :sender,
                   :conditions => "messages.read_at IS NULL",
                   :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"
          
          has_many :read_messages,
                   :through => :messages_as_receiver,
                   :source => :sender,
                   :conditions => "messages.read_at IS NOT NULL",
                   :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"
                   
          has_many :inbox_messages,  
                   :class_name => "Message", 
                   :foreign_key => "receiver_id",
                   :conditions => ["receiver_deleted = ?", false],
                   :order => "created_at DESC"
                   
          has_many :outbox_messages,  
                   :class_name => "Message", 
                   :foreign_key => "sender_id",
                   :conditions => ["sender_deleted = ?", false],
                   :order => "created_at DESC"
          
          has_many :trashbin_messages,  
                   :class_name => "Message", 
                   :foreign_key => "receiver_id",
                   :conditions => ["receiver_deleted = ? and receiver_purged = ?", true, false],
                   :order => "created_at DESC"

          include ProtonMicro::RestfulEasyMessages::Messages::InstanceMethods
        end
      end

      module InstanceMethods
        # Returns a list of all the users who the user has messaged
        def users_messaged
          self.users_whom_i_have_messaged
        end
  
        # Returns a list of all the users who have messaged the user
        def users_messaged_by
          self.users_who_messaged_me
        end
  
        # Returns a list of all the users who the user has mailed or been mailed by
        def all_messages
          self.users_messaged + self.users_messaged_by
        end
  
        # Alias for unread messages
        def new_messages
          self.unread_messages
        end
  
        # Alias for read messages
        def old_messages
          self.read_messages
        end
        
        # Accepts an email object and flags the email as deleted by sender
        def delete_from_sent(message)
          if message.sender_id == self.id
            message.update_attribute :sender_deleted, true
            return true
          else
            return false
          end
        end
  
        # Accepts an email object and flags the email as deleted by receiver
        def delete_from_received(message)
          if message.receiver_id == self.id
            message.update_attribute :receiver_deleted, true
            return true
          else
            return false
          end
        end
  
        # Accepts a user object as the receiver, and an email
        # and creates an email relationship joining the two users
        def send_message(receiver, message)
          Message.create!(:sender => self, :receiver => receiver, :subject => message.subject, :body => message.body)
        end        
      end   
    end
  end
end