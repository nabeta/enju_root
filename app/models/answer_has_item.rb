class AnswerHasItem < ActiveRecord::Base
  include LibrarianOwnerRequired
  belongs_to :answer
  belongs_to :item

  validates_uniqueness_of :item_id, :scope => :answer_id
end
