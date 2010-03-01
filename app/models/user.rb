# -*- encoding: utf-8 -*-
class User < ActiveRecord::Base
  # ---------------------------------------
  # The following code has been generated by role_requirement.
  # You may wish to modify it to suit your need
  has_and_belongs_to_many :roles
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("Administrator")
    if @_list.include?("Librarian")
      return true if role_in_question.to_s == "User"
    end
    (@_list.include?(role_in_question.to_s) )
  end
  # ---------------------------------------
  
  named_scope :administrators, :include => ['roles'], :conditions => ['roles.name = ?', 'Administrator']
  named_scope :librarians, :include => ['roles'], :conditions => ['roles.name = ?', 'Librarian']
  named_scope :suspended, :conditions => {:active => false}

  searchable :auto_index => false do
    text :login, :email, :note, :user_number
    text :name do
      patron.name if patron
    end
    string :login
    string :email
    string :user_number
    integer :required_role_id
    time :created_at
    time :updated_at
    boolean :active
    boolean :confirmed
    boolean :approved
  end

  has_one :patron
  #belongs_to :patron, :polymorphic => true
  has_many :questions
  has_many :answers
  #has_many :checkins, :dependent => :destroy
  #has_many :checkin_items, :through => :checkins
  has_many :checkouts, :dependent => :destroy
  #has_many :checkout_items, :through => :checkouts
  has_many :reserves, :dependent => :destroy
  has_many :reserved_manifestations, :through => :reserves, :source => :manifestation
  has_many :bookmarks, :dependent => :destroy
  has_many :manifestations, :through => :bookmarks
  has_many :search_histories, :dependent => :destroy
  has_many :baskets, :dependent => :destroy
  belongs_to :user_group #, :validate => true
  has_many :purchase_requests
  belongs_to :library, :counter_cache => true, :validate => true
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  #has_one :imported_object, :as => :importable
  has_many :order_lists
  has_many :subscriptions
  has_many :checkout_stat_has_users
  has_many :user_checkout_stats, :through => :checkout_stat_has_users
  has_many :reserve_stat_has_users
  has_many :user_reserve_stats, :through => :reserve_stat_has_users
  has_many :news_posts
  has_many :user_has_shelves, :dependent => :destroy
  has_many :shelves, :through => :user_has_shelves
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_many :import_requests

  restful_easy_messages
  #acts_as_soft_deletable
  has_friendly_id :login
  acts_as_tagger

  acts_as_authentic {|c|
    c.merge_validates_format_of_email_field_options :allow_blank => false, :on => :create
    c.merge_validates_format_of_email_field_options :allow_blank => true, :on => :update
    c.merge_validates_length_of_email_field_options :allow_blank => true, :on => :update
    c.merge_validates_uniqueness_of_email_field_options :allow_blank => true
    c.validates_length_of_password_field_options = {:on => :update, :minimum => 8, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 8, :if => :has_no_credentials?}
  }

  def self.per_page
    10
  end
  
  # Virtual attribute for the unencrypted password
  attr_accessor :old_password, :temporary_password
  attr_reader :auto_generated_password
  attr_accessor :first_name, :middle_name, :last_name, :full_name, :first_name_transcription, :middle_name_transcription, :last_name_transcription, :full_name_transcription
  attr_accessor :zip_code, :address, :telephone_number, :fax_number, :address_note, :role_id
  attr_accessor :patron_id, :operator, :password_not_verified, :update_own_account
  attr_accessible :login, :email, :password, :password_confirmation, :openid_identifier, :old_password

  validates_presence_of :login
  #validates_length_of       :login,    :within => 2..40
  #validates_uniqueness_of   :login,    :case_sensitive => false

  validates_presence_of     :email, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
  #validates_length_of       :email,    :within => 6..100, :if => proc{|user| !user.email.blank?}, :allow_nil => true
  #validates_uniqueness_of   :email, :case_sensitive => false, :if => proc{|user| !user.email.blank?}, :allow_nil => true
  #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true
  validates_associated :patron, :user_group, :library
  #validates_presence_of :patron, :user_group, :library
  validates_presence_of :user_group, :library, :locale #, :patron
  #validates_uniqueness_of :user_number, :with=>/\A[0-9]+\Z/, :allow_blank => true
  validates_uniqueness_of :user_number, :with=>/\A[0-9A-Za-z_]+\Z/, :allow_blank => true
  validate_on_update :verify_password
  #validates_acceptance_of :confirmed

  def verify_password
    errors.add(:old_password) if self.password_not_verified
  end

  #before_create :reset_checkout_icalendar_token, :reset_answer_feed_token

  #def before_validation
  #  self.full_name = self.patron.full_name if self.patron
  #end

  def validate
    if update_own_account
      errors.add(:active) if self.changed.include?('active')
      errors.add(:confirmed) if self.changed.include?('confirmed')
      errors.add(:approved) if self.changed.include?('approved')
    end
  end

  def before_validation_on_create
    self.required_role = Role.find_by_name('Librarian')
    self.locale = I18n.default_locale
    unless self.patron
      self.patron = Patron.create(:full_name => self.login) if self.login
    end
  end

  def after_save
    unless last_request_at_changed?
      if self.patron
        self.patron.index
      end
      index
    end
  end

  def before_save
    return if self.has_role?('Administrator')
    locked = nil
    unless self.expired_at.blank?
      locked = true if self.expired_at.beginning_of_day < Time.zone.now.beginning_of_day
    end
    #locked = true if self.user_number.blank?

    self.active = false if locked
  end

  def before_destroy
    check_item_before_destroy
    check_role_before_destroy
  end

  def after_destroy
    self.patron.index
    remove_from_index
  end

  def check_item_before_destroy
    # TODO: 貸出記録を残す場合
    if checkouts.size > 0
      raise 'This user has items still checked out.'
    end
  end

  def check_role_before_destroy
    if self.has_role?('Administrator')
      raise 'This is the last administrator in this system.' if Role.find_by_name('Administrator').users.size == 1
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.valid_password?(password) ? u : nil
  end

  def set_auto_generated_password
    self.temporary_password = reset_password
  end

  def reset_checkout_icalendar_token
    self.checkout_icalendar_token = Authlogic::Random.friendly_token
  end

  def delete_checkout_icalendar_token
    self.checkout_icalendar_token = nil
  end

  def reset_answer_feed_token
    self.answer_feed_token = Authlogic::Random.friendly_token
  end

  def delete_answer_feed_token
    self.answer_feed_token = nil
  end

  def lock!
    self.active = false
    save(false)
  end

  def suspended?
    return true unless self.active?
    false
  end

  def self.lock_expired_users
    User.find_each do |user|
      user.lock! if user.expired?
    end
  end

  def expired?
    if expired_at
      true if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
    end
  end

  def activate
    self.active = true
    self.confirmed = true
    self.approved = true
    self.roles << Role.find(2)
  end

  def activate!
    activate
    # TODO: パトロン作成のタイミングを決める
    #self.patron = Patron.create(:full_name => self.login) unless self.patron
    save
  end

  def checked_item_count
    checkout_count = {}
    CheckoutType.all.each do |checkout_type|
      # 資料種別ごとの貸出中の冊数を計算
      checkout_count[:"#{checkout_type.name}"] = self.checkouts.count_by_sql(["
        SELECT count(item_id) FROM checkouts
          WHERE item_id IN (
            SELECT id FROM items
              WHERE checkout_type_id = ?
          )
          AND user_id = ? AND checkin_id IS NULL", checkout_type.id, self.id]
      )
    end
    return checkout_count
  end

  def reached_reservation_limit?(manifestation)
    return true if self.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).all(:conditions => {:user_group_id => self.user_group.id}).collect(&:reservation_limit).max <= self.reserves.waiting.size
    false
  end

  def highest_role
    self.roles.first(:order => ['id DESC'])
  end

  def is_admin?
    true if self.has_role?('Administrator')
  end

  def self.is_indexable_by(user, parent = nil)
    if user.try(:has_role?, 'Librarian')
      true
    else
      false
    end
  end

  def self.is_creatable_by(user, parent = nil)
    true
  # true if user.has_role?('Librarian')
  #rescue
  #  false
  end

  def is_readable_by(user, parent = nil)
    if user.try(:has_role?, 'User')
      true
    else
      false
    end
  end

  def is_updatable_by(user, parent = nil)
    return true if user == self || user.try(:has_role?, 'Librarian')
    false
  end

  def is_deletable_by(user, parent = nil)
    raise if self.id == 1 || self.checkouts.size > 0 || self.last_librarian?
    true if user == self || user.has_role?('Librarian')
  rescue
    false
  end

  def last_librarian?
    if self.has_role?('Librarian')
      role = Role.first(:conditions => {:name => 'Librarian'})
      true if role.users.size == 1
    end
  end

  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end

  def set_role(role)
    if self.role_id
      User.transaction do
        self.roles.delete_all
        self.roles << role
      end
    end
  end

  def send_message(status, options = {})
    MessageRequest.transaction do
      request = MessageRequest.new
      request.sender = User.find(1) # TODO: システムからのメッセージ送信者
      request.receiver = self
      request.message_template = MessageTemplate.find_by_status(status)
      request.embed_body(options)
      request.save!
      request.aasm_send_message!
    end
  end

  def owned_tags_by_solr
    bookmark_ids = bookmarks.collect(&:id)
    if bookmark_ids.empty?
      []
    else
      Tag.bookmarked(bookmark_ids)
    end
  end

  def check_update_own_account(user)
    if user == self
      self.update_own_account = true
      return true
    end
    false
  end

  def has_no_credentials?
    crypted_password.blank? && openid_identifier.blank?
  end
        
  def signup!(params)
    login = params[:user][:login]
    email = params[:user][:email]
    roles << Role.find(2)
    save_without_session_maintenance
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    Notifier.deliver_activation_instructions(self)
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    Notifier.deliver_activation_confirmation(self)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  private
  def validate_password_with_openid?
    require_password?
  end

end
