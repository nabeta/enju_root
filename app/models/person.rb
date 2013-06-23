class Person < ActiveRecord::Base
  attr_accessible :full_name,
    :work_id, :expression_id, :manifestation_id
  has_many :creates, :dependent => :destroy
  has_many :works, :through => :creates
  has_many :realizes, :dependent => :destroy
  has_many :expressions, :through => :realizes
  has_many :produces, :dependent => :destroy
  has_many :manifestations, :through => :produces

  validates :full_name, :presence => true

  searchable do
    text :full_name
    integer :work_ids, :multiple => true
    integer :expression_ids, :multiple => true
    integer :manifestation_ids, :multiple => true
  end

  attr_accessor :work_id, :expression_id, :manifestation_id
end
