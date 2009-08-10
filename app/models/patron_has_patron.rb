class PatronHasPatron < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_patron, :foreign_key => 'from_patron_id', :class_name => 'Patron'
  belongs_to :to_patron, :foreign_key => 'to_patron_id', :class_name => 'Patron'

  validates_uniqueness_of :from_patron_id, :scope => :to_patron_id

  acts_as_list :scope => :from_patron

  def before_save
    self.from_patron.save
    self.to_patron.save
  end
end
