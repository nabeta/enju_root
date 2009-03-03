class Family < ActiveRecord::Base
  belongs_to :country
  belongs_to :language
  has_one :user, :dependent => :destroy, :as => :patron
  #has_many :works
  #has_many :expressions
  #has_many :manifestations
  #has_many :items

  validates_presence_of :full_name
  acts_as_solr :fields => [:name, {:required_role_id => :integer}]
  acts_as_soft_deletable

  def check_required_role(user)
    true
  end

  def name
    full_name
  end
end
