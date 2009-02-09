class Person < ActiveRecord::Base
  belongs_to :language
  has_many :works
  has_many :expressions
  has_many :manifestations
  has_many :items

  validates_presence_of :full_name
  acts_as_solr :fields => [:full_name, {:access_role_id => :integer}]
  acts_as_soft_deletable

  def check_access_role(user)
    true
  end
end
