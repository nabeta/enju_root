class Exemplify < ActiveRecord::Base
  belongs_to :manifestation
  belongs_to :item
  # attr_accessible :title, :body

  after_save :create_index

  def create_index
    manifestation.index
    item.index
    Sunspot.commit
  end
end
