class Subscription < ActiveRecord::Base
  include LibrarianRequired
  has_many :subscribes, :dependent => :destroy
  has_many :manifestations, :through => :subscribes
  belongs_to :user, :validate => true
  belongs_to :order_list, :validate => true

  validates_presence_of :title, :user
  validates_associated :user

  searchable do
    text :title, :note
    time :created_at
    time :updated_at
    integer :manifestation_ids, :multiple => true
  end
  #acts_as_soft_deletable
  #acts_as_solr :fields => [:title, :note,
  #  {:created_at => :date}, {:updated_at => :date},
  #  {:manifestation_ids => :integer}]

  @@per_page = 10
  cattr_accessor :per_page

end
