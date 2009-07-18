class Item < ActiveRecord::Base
  include OnlyLibrarianCanModify
  include EnjuFragmentCache

  named_scope :not_for_checkout, :conditions => ['item_identifier IS NULL']
  named_scope :on_shelf, :conditions => ['shelf_id != 1']
  named_scope :on_web, :conditions => ['shelf_id = 1']
  has_one :exemplify, :dependent => :destroy
  has_one :manifestation, :through => :exemplify #, :include => :manifestation_form
  #has_many :checkins
  #has_many :checkin_patrons, :through => :checkins
  has_many :checkouts
  #has_many :checkout_users, :through => :checkouts
  has_many :reserves
  has_many :reserved_patrons, :through => :reserves
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  has_many :checked_items, :dependent => :destroy
  has_many :baskets, :through => :checked_items
  belongs_to :circulation_status, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  #has_one :order
  has_many :item_has_use_restrictions, :dependent => :destroy
  has_many :use_restrictions, :through => :item_has_use_restrictions
  has_many :reserves
  has_many :resource_has_subjects, :as => :subjectable, :dependent => :destroy
  has_many :subjects, :through => :resource_has_subjects
  has_many :inter_library_loans, :dependent => :destroy
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  #has_one :item_has_checkout_type, :dependent => :destroy
  belongs_to :checkout_type #, :through => :item_has_checkout_type
  has_one :barcode, :as => :barcodable, :dependent => :destroy
  has_many :inventories, :dependent => :destroy
  has_many :inventory_files, :through => :inventories
  has_many :to_items, :foreign_key => 'from_item_id', :class_name => 'ItemHasItem', :dependent => :destroy
  has_many :from_items, :foreign_key => 'to_item_id', :class_name => 'ItemHasItem', :dependent => :destroy
  has_many :derived_items, :through => :to_items, :source => :to_item
  has_many :original_items, :through => :from_items, :source => :from_item
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :owns
  
  validates_associated :circulation_status, :shelf, :bookstore, :checkout_type
  validates_presence_of :circulation_status #, :checkout_type
  validates_uniqueness_of :item_identifier, :allow_blank => true, :if => proc{|item| !item.item_identifier.blank?}
  validates_length_of :url, :maximum => 255, :allow_blank => true
  validates_format_of :item_identifier, :with=>/\A[0-9]+\Z/, :allow_blank => true

  #acts_as_taggable_on :tags
  #acts_as_soft_deletable
  enju_union_catalog

  acts_as_solr :fields => [:item_identifier, :note, :title, :author,
    :publisher, :library, {:required_role_id => :range_integer},
    {:original_item_ids => :integer}],
    :facets => [:circulation_status_id],
    #:if => proc{|item| item.indexing}, :auto_commit => false
    :offline => proc{|item| !item.indexing}, :auto_commit => false

  cattr_accessor :per_page
  @@per_page = 10
  attr_accessor :indexing

  #def after_create
  #  post_to_union_catalog
  #end

  #def after_update
  #  update_union_catalog
  #end

  #def after_destroy
  #  remove_from_union_catalog
  #end

  def before_save
    set_item_identifier
  end

  def after_save
  #  unless self.item_identifier.blank?
  #    self.barcode = Barcode.create(:code_word => self.item_identifier) if self.barcode
  #  end
  # TODO: 排架場所変更の際のインデックス更新のタイミング
  #  self.manifestation.send_later(:save, false) if self.manifestation
  end

  def before_validation_on_create
    self.circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'In Process'}) if self.circulation_status.nil?
  end

  def before_validation
    self.item_identifier = nil if self.item_identifier.blank?
  end

  def checkout_status(user)
    user.user_group.user_group_has_checkout_types.find_by_checkout_type_id(self.checkout_type.id)
  end

  def next_reservation
    Reserve.waiting.find(:first, :conditions => {:manifestation_id => self.manifestation.id})
  end

  def reserved?
    return true if self.next_reservation
    false
  end

  def reservable?
    return false if ['Lost', 'Missing', 'Claimed Returned Or Never Borrowed'].include?(self.circulation_status.name)
    return false if self.item_identifier.blank?
    true
  end

  def rent?
    return true if self.checkouts.not_returned.detect{|checkout| checkout.item_id == self.id}
    false
  end

  def reserved_by_user?(user)
    if self.next_reservation
      return true if self.next_reservation.user == user
    end
    false
  end

  def available_for_checkout?
    circulation_statuses = Rails.cache.fetch('CirculationStatus.available_for_checkout'){CirculationStatus.available_for_checkout}
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def checkout!(user)
    Item.transaction do
      self.circulation_status = Rails.cache.fetch('CirculationStatus.on_loan'){CirculationStatus.find(:first, :conditions => {:name => 'On Loan'})}
      if self.reserved_by_user?(user)
        self.next_reservation.update_attributes(:checked_out_at => Time.zone.now)
        self.next_reservation.aasm_complete!
      end
      save(false)
    end
  end

  def checkin!
    self.circulation_status = Rails.cache.fetch('CirculationStatus.available_on_shelf'){CirculationStatus.find(:first, :conditions => {:name => 'Available On Shelf'})}
    save(false)
  end

  def retain(librarian)
    Item.transaction do
      reservation = self.manifestation.next_reservation
      unless reservation.nil?
        reservation.item = self
        reservation.aasm_retain!
        reservation.update_attributes({:request_status_type => RequestStatusType.find_by_name('Available For Pickup')})
        queue = MessageQueue.new(:sender_id => librarian.id, :receiver_id => reservation.user_id)
        message_template = MessageTemplate.find_by_status('item_received')
        queue.message_template = message_template
        queue.save!
      end
    end
  end

  def inter_library_loaned?
    true if self.inter_library_loans.size > 0
  end

  def title
    self.manifestation.original_title if self.manifestation
  end

  def author
    self.manifestation.author if self.manifestation
  end

  def publisher
    self.manifestation.publisher if self.manifestation
  end

  def library
    self.shelf.library.name if self.shelf
  end

  def hold?(library)
    return true if self.shelf.library == library
    false
  end

  def self.inventory_items(inventory_file, mode = 'not_on_shelf')
    item_ids = Item.find(:all, :select => :id).collect(&:id)
    inventory_item_ids = inventory_file.items.find(:all, :select => ['items.id']).collect(&:id)
    case mode
    when 'not_on_shelf'
      Item.find(item_ids - inventory_item_ids)
    when 'not_in_catalog'
      Item.find(inventory_item_ids - item_ids)
    end
  rescue
    nil
  end

  def set_item_identifier
    if self.item_identifier
      self.item_identifier.strip!
      #send_later(:create_barcode)
    else
      self.item_identifier = nil
    end
  end

  def create_barcode
    unless self.item_identifier.blank?
      barcode = Barcode.find(:first, :conditions => {:code_word => self.item_identifier})
      if barcode.nil?
        barcode = Barcode.create(:code_word => self.item_identifier)
      end

      self.barcode = barcode
      self.barcode.save(false)
    end
  end

end
