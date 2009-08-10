class Message < ActiveRecord::Base

  attr_accessor :recipient
  
  belongs_to :sender,
             :class_name => "User",
             :foreign_key => "sender_id",
             :validate => true
                     
  belongs_to :receiver,
             :class_name => "User",
             :foreign_key => "receiver_id",
             :validate => true

  validates_presence_of :recipient, 
                        :subject,
                        :body
                        
  validates_length_of :body, 
                      :minimum => 1
                      #:message => ("is too short.  The minimum length is %d characters. Please don't spam.")
                      #:message => I18n.t('message.too_short', :count => :minimum)
                      
  validates_length_of :body, 
                      :maximum => 10000
                      #:message => ("is too long.  No one wants to read that.  The maximum length is %d characters.")
                      #:message => I18n.t('message.too_long', :count => :maximum)

  belongs_to :message_queue

  cattr_accessor :per_page
  @@per_page = 10

  searchable :auto_index => false do
    text :body, :subject
    string :subject
    integer :receiver_id
    integer :sender_id
    time :created_at
    time :read_at
    boolean :sender_deleted do
      sender_deleted ? true : false
    end
    boolean :receiver_deleted do
      receiver_deleted ? true : false
    end
    boolean :sender_purged do
      sender_purged ? true : false
    end
    boolean :receiver_purged do
      receiver_purged ? true : false
    end
  end

  def after_create
    Notifier.deliver_message_notification(self.receiver)
  end

  # Returns user.login for the sender
  def sender_name
    User.find(sender_id).login || ""
  end
  
  # Returns user.login for the receiver
  def receiver_name
    User.find(receiver_id).login || ""
  end
  
  def mark_message_read(user)
    if user.id == self.receiver_id
      self.read_at = Time.zone.now
      self.save false
    end
  end
  
  # Performs a hard delete of a message.  Should only be called from destroy
  def purge
    if self.sender_purged && self.receiver_purged
      self.destroy
    end
  end
  
  # Assigns the recipient to the receiver_id.
  # I'm sure there is a better way.  Please let me know.
  def before_create
    #u = User.find_by_login(recipient)
    u = User.find_by_login(recipient)
    self.receiver_id = u.id
  end
  
  # Validates that a user has entered a valid user.login name for the message recipient
  def validate_on_create
    #u = User.find_by_login(recipient)
    u = User.find_by_login(recipient)
    errors.add(:recipient, ('is not a valid user.')) if u.nil?
  end

end
