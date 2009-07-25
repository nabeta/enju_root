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
  named_scope :suspended, :conditions => {:suspended => true}

  searchable :auto_index => false do
    text :login, :email, :note
    text :name do
      patron.name if patron
    end
    string :login
    string :email
    integer :required_role_id
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
  has_many :bookmarked_resources, :through => :bookmarks
  has_many :search_histories, :dependent => :destroy
  has_many :baskets, :dependent => :destroy
  belongs_to :user_group #, :validate => true
  has_many :purchase_requests
  belongs_to :library, :counter_cache => true, :validate => true
  has_many :imported_files
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  has_many :imported_resources
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

  restful_easy_messages
  #acts_as_soft_deletable
  has_friendly_id :login
  acts_as_tagger

  cattr_accessor :per_page
  @@per_page = 10
  
  # Virtual attribute for the unencrypted password
  attr_accessor :old_password, :temporary_password
  attr_reader :auto_generated_password
  attr_accessor :first_name, :middle_name, :last_name, :full_name, :first_name_transcription, :middle_name_transcription, :last_name_transcription, :full_name_transcription
  attr_accessor :zip_code, :address, :telephone_number, :fax_number, :address_note, :role_id
  attr_accessor :patron_id, :operator, :password_not_verified
  attr_accessible :login, :email, :password, :password_confirmation, :openid_identifier, :old_password

  #validates_length_of       :login,    :within => 2..40
  #validates_uniqueness_of   :login,    :case_sensitive => false

  #validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100, :if => Proc.new{|user| !user.email.blank?}, :allow_nil => true
  validates_uniqueness_of   :email, :case_sensitive => false, :if => proc{|user| !user.email.blank?}, :allow_nil => true
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true
  validates_associated :patron, :user_group, :library
  #validates_presence_of :patron, :user_group, :library
  validates_presence_of :user_group, :library, :locale
  #validates_presence_of :user_number
  validates_uniqueness_of :user_number, :with=>/\A[0-9]+\Z/, :allow_blank => true
  validate_on_update :verify_password

  acts_as_authentic {|c|
    c.validate_email_field = false
  }

  def verify_password
    errors.add(:old_password) if self.password_not_verified
  end

  #before_create :reset_checkout_icalendar_token, :reset_answer_feed_token

  #def before_validation
  #  self.full_name = self.patron.full_name if self.patron
  #end

  def after_save
    # TODO: last_request_atを無効にすることも考える
    unless last_request_at_changed?
      if self.patron
        self.patron.send_later(:save)
      end
    end
  end

  def after_destroy
    after_save
  end

  def before_validation_on_create
    self.required_role = Role.find_by_name('Librarian')
    self.locale = I18n.default_locale
  end

  def set_auto_generated_password
    self.temporary_password = reset_password
  end

  def before_save
    return if self.has_role?('Administrator')
    lock = nil
    unless self.expired_at.blank?
      lock = true if self.expired_at.beginning_of_day < Time.zone.now.beginning_of_day
    end
    #lock = true if self.user_number.blank?

    self.suspended = true if lock
  end

  def before_destroy
    check_item_before_destroy
    check_role_before_destroy
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

  def lock
    self.suspended = true
    save(false)
  end

  def suspended?
    return true if self.suspended
    false
  end

  def activate
    self.suspended = false
  end

  def checked_item_count
    checkout_count = {}
    CheckoutType.find(:all).each do |checkout_type|
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
    return true if self.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).find(:all, :conditions => {:user_group_id => self.user_group.id}).collect(&:reservation_limit).max <= self.reserves.waiting.size
    false
  end

  def highest_role
    self.roles.find(:first, :order => ['id DESC'])
  end

  def is_admin?
    true if self.has_role?('Administrator')
  end

  def self.is_indexable_by(user, parent = nil)
    true if user.has_role?('Librarian')
  rescue
    false
  end

  def self.is_creatable_by(user, parent = nil)
    true
  # true if user.has_role?('Librarian')
  #rescue
  #  false
  end

  def is_readable_by(user, parent = nil)
    true if user.has_role?('User')
  rescue
    false
  end

  def is_updatable_by(user, parent = nil)
    true if user == self || user.has_role?('Librarian')
  rescue
    false
  end

  def is_deletable_by(user, parent = nil)
    raise if self.id == 1 or self.checkouts.size > 0 or self.last_librarian?
    true if user == self || user.has_role?('Librarian')
  rescue
    false
  end

  def last_librarian?
    if self.has_role?('Librarian')
      role = Role.find(:first, :conditions => {:name => 'Librarian'})
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
    queue = MessageQueue.new
    queue.sender = User.find(1) # TODO: システムからのメッセージ送信者
    queue.receiver = self
    queue.message_template = MessageTemplate.find_by_status(status)
    queue.embed_body(options)
    queue.save!
    queue.aasm_send_message!
  end

  private
  def validate_password_with_openid?
    require_password?
  end

end
