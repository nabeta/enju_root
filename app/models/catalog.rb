class Catalog < ActiveRecord::Base
  attr_accessible :name, :url
  validates :name, :presence => true
  validates :url, :presence => true
end
