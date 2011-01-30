# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  scope :for_checkout, :conditions => ['item_identifier IS NOT NULL']
  scope :not_for_checkout, :conditions => ['item_identifier IS NULL']
  scope :on_shelf, :conditions => ['shelf_id != 1']
  scope :on_web, :conditions => ['shelf_id = 1']
  #belongs_to :manifestation, :class_name => 'Resource'
  has_one :exemplify
  has_one :manifestation, :through => :exemplify
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  belongs_to :circulation_status, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  has_many :item_has_use_restrictions, :dependent => :destroy
  has_many :use_restrictions, :through => :item_has_use_restrictions
  has_many :inter_library_loans, :dependent => :destroy
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :answer_has_items, :dependent => :destroy
  has_many :answers, :through => :answer_has_items
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ItemRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ItemRelationship', :dependent => :destroy
  has_many :derived_items, :through => :children, :source => :child
  has_many :original_items, :through => :parents, :source => :parent
  has_one :resource_import_result
  
  validates_associated :circulation_status, :shelf
  validates_presence_of :circulation_status
  validates_uniqueness_of :item_identifier, :allow_blank => true, :if => proc{|item| !item.item_identifier.blank?}
  validates_length_of :url, :maximum => 255, :allow_blank => true
  validates_format_of :item_identifier, :with=>/\A\w+\Z/, :allow_blank => true
  before_validation :set_circulation_status, :on => :create
  #after_create :create_lending_policy
  #after_save :save_manifestation
  #after_destroy :save_manifestation

  #enju_union_catalog
  has_paper_trail
  normalize_attributes :item_identifier

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher, :library
    string :item_identifier
    string :library
    integer :required_role_id
    integer :circulation_status_id
    integer :manifestation_id do
      manifestation.id if manifestation
    end
    integer :shelf_id
    integer :patron_ids, :multiple => true
    time :created_at
    time :updated_at
    integer :original_item_ids, :multiple => true
  end

  attr_accessor :library_id, :manifestation_id
  alias :owners :patrons

  def self.per_page
    10
  end

  def save_manifestation
    #self.manifestation.save(:validation => false) if self.manifestation
  end

  def set_circulation_status
    self.circulation_status = CirculationStatus.first(:conditions => {:name => 'In Process'}) if self.circulation_status.nil?
  end

  def available_for_checkout?
    circulation_statuses = CirculationStatus.available_for_checkout
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def checkout!(user)
    self.circulation_status = CirculationStatus.first(:conditions => {:name => 'On Loan'})
    save!
  end

  def checkin!
    self.circulation_status = CirculationStatus.first(:conditions => {:name => 'Available On Shelf'})
    save!
  end

  def inter_library_loaned?
    true if self.inter_library_loans.size > 0
  end

  def title
    manifestation.try(:original_title)
  end

  def creator
    manifestation.try(:creator)
  end

  def contributor
    manifestation.try(:contributor)
  end

  def publisher
    manifestation.try(:publisher)
  end

  def library
    shelf.library.name if shelf
  end

  def shelf_name
    shelf.name
  end

  def hold?(library)
    return true if self.shelf.library == library
    false
  end

  def lending_rule(user)
    lending_policies.first(:conditions => {:user_group_id => user.user_group.id})
  end

  def owned(patron)
    owns.first(:conditions => {:patron_id => patron.id})
  end

  def library_url
    "#{LibraryGroup.url}libraries/#{self.shelf.library.name}"
  end

  def manifestation_url
    URI.parse("#{LibraryGroup.url}manifestations/#{self.manifestation.id}").normalize.to_s if self.manifestation
  end
end
