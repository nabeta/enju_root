# -*- encoding: utf-8 -*-
class Message < ActiveRecord::Base
  include AASM
  named_scope :unread, :conditions => ['state = ?', 'unread']
  belongs_to :message_request
  belongs_to :sender, :class_name => 'User'
  belongs_to :receiver, :class_name => 'User'
  validates_presence_of :subject, :body, :sender
  validates_presence_of :recipient, :on => :create
  validates_presence_of :receiver, :on => :update

  acts_as_tree
  attr_accessor :recipient

  aasm_column :state
  aasm_state :read
  aasm_state :unread
  aasm_initial_state :unread

  aasm_event :aasm_read do
    transitions :from => [:read, :unread], :to => :read
  end

  aasm_event :aasm_unread do
    transitions :from => :read, :to => :unread
  end

  def before_save
    if self.recipient
      self.receiver = User.find(self.recipient)
    end
  end

  def self.per_page
    10
  end

  searchable do
    text :body, :subject
    string :subject
    integer :receiver_id
    integer :sender_id
    time :created_at
  end

  def after_save
    expire_top_page_cache
    index
  end

  def after_create
    Notifier.send_later :deliver_message_notification, self.receiver if self.receiver.try(:email).present?
  end

  def after_destroy
    expire_top_page_cache
    remove_from_index
  end

  def expire_top_page_cache
    I18n.available_locales.each do |locale|
      Rails.cache.delete("views/#{LIBRARY_WEB_HOSTNAME}/users/#{receiver.username}?action_suffix=header&locale=#{locale}")
    end
  end

  # Returns user.login for the sender
  def sender_name
    User.find(sender_id).username || ""
  end
  
  # Returns user.login for the receiver
  def receiver_name
    User.find(receiver_id).username || ""
  end
  
  def mark_message_read(user)
    if user.id == self.receiver_id
      #self.read_at = Time.zone.now
      #self.save false
    end
  end

  def read?
    return true if state == 'read'
    false
  end
  
end
