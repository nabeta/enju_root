class Subscription < ActiveRecord::Base
  include LibrarianRequired
  has_many :subscribes, :dependent => :destroy
  has_many :expressions, :through => :subscribes
  belongs_to :user, :validate => true
  belongs_to :order_list, :validate => true

  validates_presence_of :title, :user
  validates_associated :user

  acts_as_soft_deletable
  acts_as_solr :fields => [:title, :note,
    {:created_at => :date}, {:updated_at => :date},
    {:expression_ids => :integer}]

  @@per_page = 10
  cattr_accessor :per_page

  def expression_ids
    self.expressions.collect(&:id)
  end

end
