class EventImportFile < ActiveRecord::Base
  include AASM
  include LibrarianRequired
  default_scope :order => 'id DESC'
  named_scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

  #has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  #validates_as_attachment
  has_attached_file :event_import, :path => ":rails_root/private:url"
  validates_attachment_content_type :event_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :imported_file, :dependent => :destroy

  aasm_column :state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :completed

  aasm_event :aasm_import do
    transitions :from => :pending, :to => :completed,
      :on_transition => :import
  end

  def import
    self.reload
    num = {:success => 0, :failure => 0}
    record = 2
    file = FasterCSV.open(self.event_import.path, :col_sep => "\t")
    rows = FasterCSV.open(self.event_import.path, :headers => file.first, :col_sep => "\t")
    file.close
    rows.shift
    rows.each do |row|
      event = Event.new
      event.title = row['title']
      event.note = row['note']
      event.start_at = row['start_at']
      event.end_at = row['end_at']
      category = row['category']
      library = Library.first(:conditions => {:name => row['library_short_name']})
      library = Library.web if library.blank?
      event.library = library
      if category == "closed"
        event.event_category = EventCagetory.first(:conditions => {:name => 'closed'})
      end

      begin
        if event.save!
          imported_object = ImportedObject.new
          imported_object.importable = event
          self.imported_objects << imported_object
          num[:success] += 1
          GC.start if record % 50 == 0
        end
      rescue
        Rails.logger.info("event import failed: column #{record}")
        num[:failure] += 1
      end
      record += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    return num
  end

  def self.import
    EventImportFile.not_imported.each do |file|
      file.aasm_import!
    end
  rescue
    logger.info "#{Time.zone.now} importing events failed!"
  end

end
