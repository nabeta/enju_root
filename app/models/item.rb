# == Schema Information
#
# Table name: items
#
#  id                          :integer          not null, primary key
#  call_number                 :string(255)
#  item_identifier             :string(255)
#  circulation_status_id       :integer          default(5), not null
#  checkout_type_id            :integer          default(1), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  shelf_id                    :integer          default(1), not null
#  basket_id                   :integer
#  include_supplements         :boolean          default(FALSE), not null
#  checkouts_count             :integer          default(0), not null
#  owns_count                  :integer          default(0), not null
#  resource_has_subjects_count :integer          default(0), not null
#  note                        :text
#  url                         :string(255)
#  price                       :integer
#  lock_version                :integer          default(0), not null
#  required_role_id            :integer          default(1), not null
#  state                       :string(255)
#  required_score              :integer          default(0), not null
#

# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  scope :for_checkout, :conditions => ['item_identifier IS NOT NULL']
  scope :not_for_checkout, where(:item_identifier => nil)
  scope :on_shelf, :conditions => ['shelf_id != 1']
  scope :on_web, where(:shelf_id => 1)
  #belongs_to :manifestation, :class_name => 'Resource'
  has_one :exemplify
  has_one :manifestation, :through => :exemplify
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  has_many :item_has_use_restrictions, :dependent => :destroy
  has_many :use_restrictions, :through => :item_has_use_restrictions
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ItemRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ItemRelationship', :dependent => :destroy
  has_many :derived_items, :through => :children, :source => :child
  has_many :original_items, :through => :parents, :source => :parent
  has_one :resource_import_result
  
  validates_associated :shelf
  validates_uniqueness_of :item_identifier, :allow_blank => true, :if => proc{|item| !item.item_identifier.blank?}
  validates_length_of :url, :maximum => 255, :allow_blank => true
  validates_format_of :item_identifier, :with => /\A\w+\Z/, :allow_blank => true

  #enju_union_catalog
  has_paper_trail
  normalize_attributes :item_identifier

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher, :library
    string :item_identifier
    string :library
    integer :required_role_id
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

  paginates_per 10

  def save_manifestation
    #self.manifestation.save(:validation => false) if self.manifestation
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
    lending_policies.where(:user_group_id => user.user_group.id).first
  end

  def owned(patron)
    owns.where(:patron_id => patron.id).first
  end

  def library_url
    "#{LibraryGroup.site_config.url}libraries/#{self.shelf.library.name}"
  end

  def manifestation_url
    URI.parse("#{LibraryGroup.site_config.url}manifestations/#{self.manifestation.id}").normalize.to_s if self.manifestation
  end
end
