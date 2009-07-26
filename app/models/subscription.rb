class Subscription < ActiveRecord::Base
  include LibrarianRequired
  has_many :subscribes, :dependent => :destroy
  has_many :manifestations, :through => :subscribes
  belongs_to :user, :validate => true
  belongs_to :order_list, :validate => true

  validates_presence_of :title, :user
  validates_associated :user

  searchable :auto_index => false do
    text :title, :note
    time :created_at
    time :updated_at
    integer :manifestation_ids, :multiple => true
  end
  #acts_as_soft_deletable

  @@per_page = 10
  cattr_accessor :per_page

end
