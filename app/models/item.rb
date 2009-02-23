class Item < ActiveRecord::Base
  include OnlyLibrarianCanModify
  has_one :exemplify, :dependent => :destroy
  has_one :manifestation, :through => :exemplify, :include => :manifestation_form
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
  belongs_to :access_role, :class_name => 'Role', :foreign_key => 'access_role_id', :validate => true
  #has_one :item_has_checkout_type, :dependent => :destroy
  belongs_to :checkout_type #, :through => :item_has_checkout_type
  has_one :barcode, :as => :barcodable, :dependent => :destroy
  has_many :inventories, :dependent => :destroy
  has_many :inventory_files, :through => :inventories
  has_many :to_items, :foreign_key => 'from_item_id', :class_name => 'ItemHasItem', :dependent => :destroy
  has_many :from_items, :foreign_key => 'to_item_id', :class_name => 'ItemHasItem', :dependent => :destroy
  has_many :derived_items, :through => :to_items, :source => :item_to_item
  has_many :original_items, :through => :from_items, :source => :item_from_item
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :owns
  
  validates_associated :circulation_status, :shelf, :bookstore, :checkout_type
  validates_presence_of :circulation_status #, :checkout_type
  validates_uniqueness_of :item_identifier, :allow_nil => true, :if => proc{|item| !item.item_identifier.blank?}
  validates_length_of :url, :maximum => 255, :allow_nil => true

  acts_as_taggable
  acts_as_soft_deletable

  acts_as_solr :fields => [:item_identifier, :note, :title, :author, :publisher, :library, {:access_role_id => :range_integer}],
    :facets => [:circulation_status_id],
    :if => proc{|item| !item.restrain_indexing}, :auto_commit => false

  cattr_reader :per_page
  @@per_page = 10
  attr_accessor :restrain_indexing

  #def after_create
  #  post_to_federated_catalog
  #end

  #def after_update
  #  update_federated_catalog
  #end

  #def after_destroy
  #  remove_from_federated_catalog
  #end

  def before_save
    unless self.item_identifier.blank?
      barcode = Barcode.find(:first, :conditions => {:code_word => self.item_identifier})
      if barcode.nil?
        barcode = Barcode.create(:code_word => self.item_identifier)
      end

      self.barcode = barcode
      self.barcode.save
    end
  end

  #def after_save
  #  unless self.item_identifier.blank?
  #    self.barcode = Barcode.create(:code_word => self.item_identifier) if self.barcode
  #  end
  #end

  def before_validation_on_create
    self.circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'In Process'}) if self.circulation_status.nil?
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
    circulation_statuses = CirculationStatus.available_for_checkout
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def checkout!(user)
    Item.transaction do
      self.circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'On Loan'})
      if self.reserved_by_user?(user)
        self.next_reservation.update_attributes(:checked_out_at => Time.zone.now)
        self.next_reservation.aasm_complete!
      end
      self.save!
    end
  end

  def checkin!
    self.circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'Available On Shelf'})
    self.save!
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
    self.shelf.library.short_name if self.shelf
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

  def post_to_federated_catalog
    local_library = self.shelf.library
    library_url = URI.parse("#{LIBRARY_WEB_URL}libraries/#{local_library.short_name}").normalize.to_s
    manifestation_url = URI.parse("#{LIBRARY_WEB_URL}manifestations/#{self.manifestation.id}").normalize.to_s
    resource = FederatedCatalog::Manifestation.find(:first, :params => {:isbn => self.manifestation.isbn})
    if resource.nil?
      #resource = FederatedCatalog::Manifestation.create(:title => self.manifestation.original_title, :library_url => library_url, :author => self.manifestation.authors.collect(&:full_name).join(" / "), :publisher => self.manifestation.publishers.collect(&:full_name).join(" / "), :isbn => self.manifestation.isbn, :local_manifestation_id => self.manifestation.id)
      resource = FederatedCatalog::Manifestation.create(:title => self.manifestation.original_title, :library_url => library_url, :author => self.manifestation.authors.collect(&:full_name).join(" / "), :publisher => self.manifestation.publishers.collect(&:full_name).join(" / "), :isbn => self.manifestation.isbn, :manifestation_url => manifestation_url)
    end

    library = FederatedCatalog::Library.find(:first, :params => {:url => library_url})
    if library.nil?
      library = FederatedCatalog::Library.create(:name => local_library.name, :url => library_url, :zip_code => local_library.zip_code, :address => local_library.address, :lat => local_library.lat, :lng => local_library.lng)
    end

    resource_url = URI.parse("http://#{FederatedCatalog.site.host}:#{FederatedCatalog.site.port}/manifestations/#{resource.id}").normalize.to_s
    #FederatedCatalog::Own.create(:manifestation_id => resource.id, :library_id => library.id, :url => manifestation_url, :library_url => library_url)
    FederatedCatalog::Own.create(:manifestation_url => resource_url, :library_url => library_url)
  end

  def update_federated_catalog
    local_library = self.shelf.library
    library_url = URI.parse("#{LIBRARY_WEB_URL}libraries/#{local_library.short_name}").normalize.to_s
    manifestation_url = URI.parse("#{LIBRARY_WEB_URL}manifestations/#{self.manifestation.id}").normalize.to_s
    own = FederatedCatalog::Own.find(:first, :params => {:url => manifestation_url, :library_url => library_url})
    own.library_url = library_url
    own.url = manifestation_url
    own.save
  end

  def remove_from_federated_catalog
    manifestation_url = URI.parse("#{LIBRARY_WEB_URL}manifestations/#{self.manifestation.id}").normalize.to_s
    own = FederatedCatalog::Own.find(:first, :params => {:url => manifestation_url})
    own.destroy
  end
end
