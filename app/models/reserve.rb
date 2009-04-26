class Reserve < ActiveRecord::Base
  include AASM
  include LibrarianOwnerRequired
  named_scope :hold, :conditions => ['item_id IS NOT NULL']
  named_scope :not_hold, :conditions => ['item_id IS NULL']
  named_scope :waiting, :conditions => ['canceled_at IS NULL AND expired_at > ?', Time.zone.now], :order => 'id DESC'
  named_scope :completed, :conditions => ['checked_out_at IS NOT NULL']
  named_scope :canceled, :conditions => ['canceled_at IS NOT NULL']
  #named_scope :expired, lambda {|start_date, end_date| {:conditions => ['checked_out_at IS NULL AND expired_at > ? AND expired_at <= ?', start_date, end_date], :order => 'expired_at'}}
  named_scope :will_expire, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state != ?', datetime, 'expired'], :order => 'expired_at'}}
  named_scope :created, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  #named_scope :expired_not_notified, :conditions => {:state => 'expired_not_notified'}
  #named_scope :expired_notified, :conditions => {:state => 'expired'}
  named_scope :not_sent_expiration_notice_to_patron, :conditions => {:state => 'expired', :expiration_notice_to_patron => false}
  named_scope :not_sent_expiration_notice_to_library, :conditions => {:state => 'expired', :expiration_notice_to_library => false}
  named_scope :sent_expiration_notice_to_patron, :conditions => {:state => 'expired', :expiration_notice_to_patron => true}
  named_scope :sent_expiration_notice_to_library, :conditions => {:state => 'expired', :expiration_notice_to_library => true}
  named_scope :not_sent_cancel_notice_to_patron, :conditions => {:state => 'canceled', :expiration_notice_to_patron => false}
  named_scope :not_sent_cancel_notice_to_library, :conditions => {:state => 'canceled', :expiration_notice_to_library => false}

  belongs_to :user, :validate => true
  belongs_to :manifestation, :validate => true
  belongs_to :librarian, :class_name => 'User', :validate => true
  belongs_to :item, :validate => true
  has_one :inter_library_loan
  belongs_to :request_status_type

  #acts_as_soft_deletable
  validates_associated :user, :manifestation, :librarian, :item, :request_status_type
  validates_presence_of :user_id, :manifestation_id, :request_status_type #, :expired_at
  #validates_uniqueness_of :manifestation_id, :scope => :user_id
  validate :manifestation_must_include_item

  cattr_accessor :per_page
  @@per_page = 10
  cattr_accessor :user_number

  aasm_initial_state :pending

  aasm_column :state
  aasm_state :pending
  aasm_state :requested
  aasm_state :retained
  aasm_state :canceled
  aasm_state :expired
  aasm_state :completed

  aasm_event :aasm_request do
    transitions :from => :pending, :to => :requested,
      :on_transition => :do_request
  end

  aasm_event :aasm_retain do
    transitions :from => :requested, :to => :retained,
      :on_transition => :retain
  end

  aasm_event :aasm_cancel do
    transitions :from => [:pending, :requested, :retained], :to => :canceled,
      :on_transition => :cancel
  end

  aasm_event :aasm_expire do
    transitions :from => [:pending, :requested, :retained], :to => :expired,
      :on_transition => :expire
  end

  aasm_event :aasm_complete do
    transitions :from => :retained, :to => :completed,
      :on_transition => :checkout
  end

  def before_validation_on_create
    self.request_status_type = RequestStatusType.find(:first, :conditions => {:name => 'In Process'})
    if self.user and self.manifestation
      if self.expired_at.blank?
        expired_period = self.manifestation.reservation_expired_period(self.user)
        self.expired_at = (expired_period + 1).days.from_now.beginning_of_day
      end
    end
  end

  def do_request
    self.update_attributes({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'In Process'})})
  end

  def manifestation_must_include_item
    unless item_id.blank?
      item = Item.find(item_id) rescue nil
      errors.add_to_base(t('reserve.invalid_item')) unless manifestation.items.include?(item)
    end
  end

  def next_reservation
    self.manifestation.reserves.find(:first, :conditions => ['reserves.id != ?', self.id], :order => ['reserves.created_at'])
  end

  #def self.reached_reservation_limit?(user, manifestation)
  #  return true if user.user_group.user_group_has_checkout_types.available_for_manifestation_form(manifestation.manifestation_form).find(:all, :conditions => {:user_group_id => user.user_group.id}).collect(&:reservation_limit).max <= user.reserves.waiting.size
  #  false
  #end

  def retain
    # TODO: 「取り置き中」の状態を正しく表す
    self.update_attributes!({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'In Process'}), :checked_out_at => Time.zone.now})
  end

  def expire
    self.update_attributes!({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Expired'}), :canceled_at => Time.zone.now})
  end

  def cancel
    self.update_attributes!({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Cannot Fulfill Request'}), :canceled_at => Time.zone.now})
  end

  def checkout
    self.update_attributes!({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Available For Pickup'}), :checked_out_at => Time.zone.now})
  end

  # この予約をしている人のほかの予約もメッセージを送ってしまう
  def send_message(status)
    system_user = User.get_cache(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      case status
      when 'accepted'
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_accepted'})
        queue = MessageQueue.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        queue.embed_body(:manifestations => Array[self.manifestation])
        queue.aasm_send_message! # 受付時は即時送信
        message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_accepted'})
        queue = MessageQueue.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_library)
        queue.embed_body(:manifestations => Array[self.manifestation])
        queue.aasm_send_message! # 受付時は即時送信
      when 'canceled'
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_canceled_for_patron'})
        queue = MessageQueue.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        queue.embed_body(:manifestations => Array[self.manifestation])
        queue.aasm_send_message! # キャンセル時は即時送信
        message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_canceled_for_library'})
        queue = MessageQueue.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
        queue.embed_body(:manifestations => Array[self.manifestation])
        queue.aasm_send_message! # キャンセル時は即時送信
      when 'expired'
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_expired_for_patron'})
        queue = MessageQueue.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        queue.embed_body(:manifestations => Array[self.manifestation])
        queue.aasm_send_message! # 期限切れ時は利用者にのみ即時送信
        self.update_attribute(:expiration_notice_to_patron, true)
      else
        raise 'status not defined'
      end
    end
  end

  def self.send_message_to_library(status)
    system_user = User.get_cache(1) # TODO: システムからのメッセージの発信者
    case status
    when 'expired'
      message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_expired_for_library'})
      queue = MessageQueue.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
      queue.embed_body(:manifestations => self.not_sent_expiration_notice_to_library.collect(&:manifestation))
      self.not_sent_expiration_notice_to_library.each do |reserve|
        reserve.update_attribute(:expiration_notice_to_library, true)
      end
    #when 'canceled'
    #  message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_canceled_for_library'})
    #  queue = MessageQueue.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
    #  queue.embed_body(:manifestations => self.not_sent_expiration_notice_to_library.collect(&:manifestation))
    #  self.not_sent_cancel_notice_to_library.each do |reserve|
    #    reserve.update_attribute(:expiration_notice_to_library, true)
    #  end
    else
      raise 'status not defined'
    end
  end

  def self.users_count(start_date, end_date, user)
    self.created(start_date, end_date).find(:all, :conditions => {:user_id => user.id}).count
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    self.created(start_date, end_date).find(:all, :conditions => {:manifestation_id => manifestation.id}).count
  end

  def self.is_indexable_by(user, parent = nil)
    true if user.has_role?('User')
  rescue
    false
  end

  def self.is_creatable_by(user, parent = nil)
    true if user.has_role?('User')
  rescue
    false
  end

  def is_updatable_by(user, parent = nil)
    raise if ['completed', 'canceled', 'expired'].include?(self.state)
    true if user == self.user || user.has_role?('Librarian')
  rescue
    false
  end

  def self.expire
    Reserve.transaction do
      reservations = Reserve.will_expire(Time.zone.now.beginning_of_day)
      reservations.find_in_batches do |reserves|
        reserves.each {|reserve|
          # キューに登録した時点では本文は作られないので
          # 予約の連絡をすませたかどうかを識別できるようにしなければならない
          # reserve.send_message('expired')
          reserve.aasm_expire!
          # reserve.expire
        }
      end
      Reserve.not_sent_expiration_notice_to_patron.each do |reserve|
        reserve.send_message('expired')
      end
      #User.find_each do |user|
      #  user.send_message('reservation_expired_for_patron')
      #end
      Reserve.send_message_to_library('expired') unless reservations.blank?
      logger.info "#{Time.zone.now} #{reservations.size} reservations expired!"
    end
  #rescue
  #  logger.info "#{Time.zone.now} expiring reservations failed!"
  end
end
