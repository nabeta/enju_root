class MessageQueue < ActiveRecord::Base
  include AASM
  include LibrarianRequired
  named_scope :not_sent, :conditions => ['sent_at IS NULL AND state != ?', 'sent']
  named_scope :sent, :conditions => {:state => 'sent'}
  belongs_to :message_template, :validate => true
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id", :validate => true
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id", :validate => true
  has_many :messages

  validates_associated :sender, :receiver, :message_template
  validates_presence_of :sender, :receiver, :message_template

  #acts_as_soft_deletable

  @@per_page = 10
  cattr_accessor :per_page

  aasm_initial_state :pending

  aasm_column :state
  aasm_state :pending
  aasm_state :sent

  aasm_event :aasm_send_message do
    transitions :from => :pending, :to => :sent,
      :on_transition => :send_message
  end

  def send_message
    message = nil
    MessageQueue.transaction do
      if self.body
        message = Message.create!(:sender => self.sender, :recipient => self.receiver.login, :subject => self.subject, :body => self.body)
      end
      self.update_attributes({:sent_at => Time.zone.now})
      Notifier.deliver_message_notification(self.receiver)
      if ['reservation_expired_for_patron', 'reservation_expired_for_patron'].include?(self.message_template.status)
        self.receiver.reserves.each do |reserve|
          reserve.update_attribute(:expiration_notice_to_patron, true)
        end
      end
    end
    return message
  end
  
  def subject
    self.message_template.title
  end

  def embed_body(options = {})
    # テンプレートに実際の本文を組み込む
    # :manifestations を指定する
    message = self.message_body(options).dup
    unless message.blank?
      library_group = LibraryGroup.site_config
      message = self.message_template.body.gsub('{receiver_full_name}', self.receiver.patron.full_name)
      message = message.gsub("{manifestations}", self.message_body(:manifestations => options[:manifestations]))
      message = message.gsub("{library_system_name}", library_group.name)
    end
    self.update_attributes!({:body => message})
  end

  def message_body(options = {})
    manifestation_message = []
    manifestations = options[:manifestations]
    unless manifestations.blank?
      manifestations.each do |manifestation|
        manifestation_message << manifestation.original_title
        manifestation_message << "\r\n"
        patrons = []
        patrons << manifestation.authors
        patrons << manifestation.editors
        patrons << manifestation.publishers
        unless patrons.flatten.blank?
          manifestation_message << "("
          manifestation_message << patrons.flatten.collect(&:full_name).join(", ")
          manifestation_message << ")"
          manifestation_message << "\r\n"
        end
        manifestation_message << "#{LibraryGroup.url}manifestations/#{manifestation.id}"
        manifestation_message << "\r\n\r\n"
      end
    end
    return manifestation_message.to_s
  end

  def self.send_messages
    count = MessageQueue.not_sent.size
    MessageQueue.not_sent.each do |queue|
      queue.aasm_send_message!
    end
    logger.info "#{Time.zone.now} sent #{count} messages!"
  end

end
