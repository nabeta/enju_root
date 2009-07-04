class ShelfHasManifestation < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :shelf
  belongs_to :manifestation

  validates_uniqueness_of :manifestation_id, :scope => :shelf_id

  acts_as_list :scope => :shelf

  @@per_page = 10
  cattr_accessor :per_page
end
