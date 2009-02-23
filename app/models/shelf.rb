class Shelf < ActiveRecord::Base
  include OnlyAdministratorCanModify
  belongs_to :library, :validate => true
  has_many :items, :include => [:use_restrictions, :circulation_status]
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy

  validates_associated :library
  validates_presence_of :name, :library
  
  acts_as_list :scope => :library
  acts_as_soft_deletable

  cattr_reader :per_page
  @@per_page = 10

  def web_shelf?
    return true if self.id == 1
    false
  end

end
