class Reify < ActiveRecord::Base
  belongs_to :work
  belongs_to :expression
  belongs_to :relationship_type
  # attr_accessible :title, :body
  attr_accessible :work_id, :expression_id, :relationship_type_id
  validates_uniqueness_of :expression_id, :scope => :work_id

  after_save :generate_graph if Setting.generate_graph
  after_save :create_index

  def create_index
    work.index
    expression.index
    Sunspot.commit
  end

  def generate_graph
    begin
      work.generate_graph
      expression.generate_graph
    rescue
      nil
    end
  end
end
