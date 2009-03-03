class ImportedEventFile < ActiveRecord::Base
  include LibrarianRequired
  named_scope :not_imported, :conditions => {:imported_at => nil}

  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :imported_file, :dependent => :destroy

  def import_events
    self.reload
    reader = CSV::Reader.create(self.db_file.data, "\t")
    header = reader.shift
    num = {:success => 0, :failure => 0}
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      event = Event.new
      event.title = data['title'].to_s.chomp
      event.note = data['note'].to_s.chomp
      event.started_at = data['started_at'].to_s.chomp
      event.ended_at = data['ended_at'].to_s.chomp
      library = Library.find(:first, :conditions => {:short_name => data['library_short_name'].to_s.chomp})
      library = Library.find(1) if library.blank?
      event.library = library
      if event.save!
        imported_object = ImportedObject.new
        imported_object.importable = event
        self.imported_objects << imported_object
        num[:success] += 1
        GC.start if num[:success] % 50 == 0
      else
        num[:failure] += 1
      end
    end
    return num
  end

end
