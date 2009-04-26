class Shelf < ActiveRecord::Base
  include OnlyAdministratorCanModify
  belongs_to :library, :validate => true
  has_many :items, :include => [:use_restrictions, :circulation_status]
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_one :user_has_shelf, :dependent => :destroy
  has_one :user, :through => :user_has_shelf

  validates_associated :library
  validates_presence_of :name, :library
  
  acts_as_list :scope => :library
  #acts_as_soft_deletable
  acts_as_cached

  cattr_accessor :per_page
  @@per_page = 10

  def before_save
    self.expire_cache
  end

  def before_destroy
    self.expire_cache
  end

  def web_shelf?
    return true if self.id == 1
    false
  end

  def self.web
    Shelf.get_cache(1)
  end

  def is_deletable_by(user, parent = nil)
    raise if self.id == 1
    true if user.has_role?('Administrator')
  rescue
    false
  end

end
