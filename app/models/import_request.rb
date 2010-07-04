class ImportRequest < ActiveRecord::Base
  default_scope :order => 'id DESC'
  belongs_to :manifestation
  belongs_to :user

  validates_presence_of :isbn, :user_id
  validates_associated :user
  #validates_uniqueness_of :isbn
  validates_length_of :isbn, :is => 13

  state_machine :initial => :pending do
    event :sm_fail do
      transition :pending => :failed
    end

    event :sm_complete do
      transition :pending => :completed
    end
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
      if manifestation = Manifestation.import_isbn!(isbn) rescue nil
        sm_complete!
        self.manifestation = manifestation; save
        manifestation.index!
      else
        sm_fail!
      end
    end
  end
end
