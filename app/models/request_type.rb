class RequestType < ActiveRecord::Base
  include AdministratorRequired
  validates_presence_of :name, :display_name
  validates_uniqueness_of :name

  acts_as_list

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end
end
