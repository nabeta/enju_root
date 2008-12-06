class Subscription < ActiveRecord::Base
  has_many :subscribes, :dependent => :destroy
  has_many :expressions, :through => :subscribes, :conditions => 'deleted_at IS NULL'
  belongs_to :user, :validate => true
  belongs_to :order_list, :validate => true

  validates_presence_of :title, :user
  validates_associated :user

  acts_as_paranoid
  acts_as_solr :fields => [:title, :note,
    {:created_at => :date}, {:updated_at => :date},
    {:expression_ids => :integer}]

  @@per_page = 10
  cattr_reader :per_page

  def expression_ids
    self.expressions.collect(&:id)
  end

end
