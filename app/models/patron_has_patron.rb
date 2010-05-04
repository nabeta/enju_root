class PatronHasPatron < ActiveRecord::Base
  belongs_to :from_patron, :foreign_key => 'from_patron_id', :class_name => 'Patron'
  belongs_to :to_patron, :foreign_key => 'to_patron_id', :class_name => 'Patron'
  belongs_to :patron_relationship_type

  validates_presence_of :from_patron, :to_patron, :patron_relationship_type
  validates_uniqueness_of :from_patron_id, :scope => :to_patron_id

  acts_as_list :scope => :from_patron

  def before_update
    Patron.find(from_patron_id_was).index
    Patron.find(to_patron_id_was).index
  end

  def after_save
    from_patron.index
    to_patron.index
  end

  def after_destroy
    after_save
  end
end
