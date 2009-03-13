class MessageQueue < ActiveRecord::Base
  include LibrarianRequired
  named_scope :not_sent, :conditions => {:sent_at => nil}
  belongs_to :message_template, :validate => true
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id", :validate => true
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id", :validate => true
  has_many :messages

  validates_associated :sender, :receiver, :message_template
  validates_presence_of :sender, :receiver, :message_template

  acts_as_soft_deletable

  @@per_page = 10
  cattr_accessor :per_page

  def send_message
    if self.body
      Message.create!(:sender => self.sender, :recipient => self.receiver.login, :subject => self.subject, :body => self.body)
      self.update_attributes({:sent_at => Time.zone.now})
    end
    #self.destroy
  end
  
  def subject
    self.message_template.title
  end

  def body
    unless self.message_body.blank?
      library_group = LibraryGroup.config
      message = self.message_template.body.gsub('{receiver_full_name}', self.receiver.patron.full_name)
      message = message.gsub("{reserved_manifestations}", self.message_body)
      message = message.gsub("{library_system_name}", library_group.name)
    end
  end

  def message_body
    # TODO: 予約以外のメッセージ
    manifestation_message = []
    case self.message_template.status
    when "reservation_accepted"
      reserves = self.receiver.reserves.not_hold.waiting
    when "item_received"
      reserves = self.receiver.reserves.hold.waiting
    when "reservation_expired_for_library"
      reserves = Reserve.will_expire(Time.zone.now.beginning_of_day)
    when "reservation_expired_for_patron"
      reserves = self.receiver.reserves.will_expire(Time.zone.now.beginning_of_day)
    end

    unless reserves.blank?
      reserves.each do |reserve|
        manifestation_message << reserve.manifestation.original_title
        manifestation_message << "\r\n"
        patrons = []
        patrons << reserve.manifestation.authors
        patrons << reserve.manifestation.editors
        patrons << reserve.manifestation.publishers
        unless patrons.flatten.blank?
          manifestation_message << "("
          manifestation_message << patrons.flatten.collect(&:full_name).join(", ")
          manifestation_message << ")"
          manifestation_message << "\r\n"
        end
        manifestation_message << "http://#{LIBRARY_WEB_HOSTNAME}/manifestations/#{reserve.manifestation.id}"
        manifestation_message << "\r\n\r\n"
      end
    end
    return manifestation_message.to_s
  end

end
