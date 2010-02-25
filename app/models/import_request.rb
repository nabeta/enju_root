class ImportRequest < ActiveRecord::Base
  include OnlyLibrarianCanModify
  include AASM

  default_scope :order => 'id DESC'
  belongs_to :manifestation
  belongs_to :user

  validates_presence_of :isbn, :user_id
  validates_associated :user
  #validates_uniqueness_of :isbn
  validates_length_of :isbn, :is => 13

  aasm_column :state
  aasm_state :pending
  aasm_state :failed
  aasm_state :completed
  aasm_initial_state :pending

  aasm_event :aasm_fail do
    transitions :from => :pending, :to => :failed
  end

  aasm_event :aasm_complete do
    transitions :from => :pending, :to => :completed
  end

  #def after_save
  #  send_later(:import)
  #end

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
    unless manifestation
      if manifestation = Manifestation.import_isbn(isbn) rescue nil
        aasm_complete!
        self.manifestation = manifestation; save
      else
        aasm_fail!
      end
    end
  end
end
