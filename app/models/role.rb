# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  include DisplayName
  include AdministratorRequired
  default_scope :order => 'position'
  has_and_belongs_to_many :users
  has_many :patrons, :foreign_key => 'required_role_id'
  has_many :people, :foreign_key => 'required_role_id'
  has_many :corporate_bodies, :foreign_key => 'required_role_id'
  has_many :families, :foreign_key => 'required_role_id'
  has_many :works, :foreign_key => 'required_role_id'
  has_many :expressions, :foreign_key => 'required_role_id'
  has_many :manifestations, :foreign_key => 'required_role_id'
  has_many :items, :foreign_key => 'required_role_id'
  #has_many :access_users, :class_name => 'User', :foreign_key => 'required_role_id'
  has_many :news_posts, :foreign_key => 'required_role_id'
  validates_presence_of :name

  acts_as_list
end
