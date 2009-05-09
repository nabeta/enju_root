class ImportedEventFile < ActiveRecord::Base
  include LibrarianRequired
  named_scope :not_imported, :conditions => {:imported_at => nil}

  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :importable, :dependent => :destroy
  has_one :imported_object, :as => :imported_file, :dependent => :destroy

  def import
    self.reload
    reader = CSV::Reader.create(self.db_file.data, "\t")
    header = reader.shift
    num = {:success => 0, :failure => 0}
    record = 2
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      data.each_value{|v| v.chomp!.to_s}
      event = Event.new
      event.title = data['title']
      event.note = data['note']
      event.started_at = data['started_at']
      event.ended_at = data['ended_at']
      category = data['category']
      library = Library.find(:first, :conditions => {:name => data['library_short_name']})
      library = Library.web if library.blank?
      event.library = library
      if category == "closed"
        event.event_category = EventCagetory.find(:first, :conditions => {:name => 'closed'})
      end

      begin
        if event.save!
          imported_object = ImportedObject.new
          imported_object.importable = event
          imported_object.imported_file = self
          imported_object.save
          num[:success] += 1
          GC.start if num[:success] % 50 == 0
        end
      rescue
        Rails.logger.info("event import failed: column #{record}")
        num[:failure] += 1
      end
      record += 1
    end
    return num
  end

  def self.import
    ImportedEventFile.not_imported.each do |file|
      file.import
    end
  rescue
    logger.info "#{Time.zone.now} importing events failed!"
  end

end
