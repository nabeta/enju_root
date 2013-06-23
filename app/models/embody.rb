class Embody < ActiveRecord::Base
  belongs_to :expression
  belongs_to :manifestation
  belongs_to :relationship_type
  # attr_accessible :title, :body
  attr_accessible :expression_id, :manifestation_id, :manifestation_url,
    :relationship_type_id
  validates_uniqueness_of :manifestation_id, :scope => :expression_id

  after_save :generate_graph if Setting.generate_graph
  after_save :create_index

  attr_accessor :manifestation_url

  def create_index
    expression.index
    manifestation.index
    Sunspot.commit
  end

  def generate_graph
    reload
    expression.generate_graph
    manifestation.generate_graph
  end
end
