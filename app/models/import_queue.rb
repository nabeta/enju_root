class ImportQueue < ActiveRecord::Base
  include OnlyLibrarianCanModify

  default_scope :order => 'id DESC'
  validates_presence_of :isbn
  validates_uniqueness_of :isbn
  validates_length_of :isbn, :is => 13
  belongs_to :manifestation

  def before_save
    send_later(:import)
  end

  def before_validation_on_create
    ISBN_Tools.cleanup!(self.isbn)
    if isbn.length == 10
      self.isbn = ISBN_Tools.isbn10_to_isbn13(self.isbn)
    end
  end

  def validate
    unless ISBN_Tools.is_valid?(isbn)
      errors.add(:isbn)
    end
  end

  def import
    manifestation = Manifestation.import_isbn(isbn)
  end
end
