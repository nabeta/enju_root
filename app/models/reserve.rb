class Reserve < ActiveRecord::Base
  include AASM
  named_scope :hold, :conditions => ['item_id IS NOT NULL']
  named_scope :not_hold, :conditions => ['item_id IS NULL']
  named_scope :waiting, :conditions => ['canceled_at IS NULL AND expired_at > ?', Time.zone.now], :order => 'id DESC'
  named_scope :completed, :conditions => ['checked_out_at IS NOT NULL']
  named_scope :canceled, :conditions => ['canceled_at IS NOT NULL']
  #named_scope :expired, lambda {|start_date, end_date| {:conditions => ['checked_out_at IS NULL AND expired_at > ? AND expired_at <= ?', start_date, end_date], :order => 'expired_at'}}
  named_scope :will_expire, lambda {|date| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state != ?', date, 'expired'], :order => 'expired_at'}}

  belongs_to :user, :validate => true
  belongs_to :manifestation, :validate => true
  belongs_to :librarian, :class_name => 'User', :validate => true
  belongs_to :item, :validate => true
  has_one :inter_library_loan
  belongs_to :request_status_type

  acts_as_soft_deletable
  validates_associated :user, :manifestation, :librarian, :item, :request_status_type
  validates_presence_of :user_id, :manifestation_id, :request_status_type #, :expired_at
  #validates_uniqueness_of :manifestation_id, :scope => :user_id
  validate :manifestation_must_include_item

  cattr_reader :per_page
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
      errors.add_to_base(('Invalid item id.')) unless manifestation.items.include?(item)
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
    self.update_attributes({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'In Process'}), :checked_out_at => Time.zone.now})
  end

  def expire
    self.update_attributes({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Expired'}), :canceled_at => Time.zone.now})
  end

  def cancel
    self.update_attributes({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Cannot Fulfill Request'}), :canceled_at => Time.zone.now})
  end

  def checkout
    self.update_attributes({:request_status_type => RequestStatusType.find(:first, :conditions => {:name => 'Available For Pickup'}), :checked_out_at => Time.zone.now})
  end

  def send_message(status)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      case status
      when 'accepted'
        system_user = User.find(1) # TODO: システムからのメッセージの発信者
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_accepted'})
        queue = MessageQueue.create(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
      when 'canceled'
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_canceled_for_patron'})
        queue = MessageQueue.create(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_canceled_for_library'})
        queue = MessageQueue.create(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
      when 'expired'
        message_template_to_patron = MessageTemplate.find(:first, :conditions => {:status => 'reservation_expired_for_patron'})
        queue = MessageQueue.create(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
      end

      unless message_template_to_patron.blank?
        message_queue = message_template_to_patron.message_queues.find_by_receiver_id(user.id) rescue nil
        if message_queue.blank?
          queue = MessageQueue.create(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
          # 即時送信
          queue.send_message
        end
      end
    end
    true
  end

  def self.send_message_to_patrons(status)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    case status
    when 'expired'
      message_template_to_library = MessageTemplate.find(:first, :conditions => {:status => 'reservation_expired_for_library'})
      queue = MessageQueue.create(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
    end
    true
  end

end
