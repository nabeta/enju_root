class ImportedResourceFile < ActiveRecord::Base
  include AASM
  include LibrarianRequired
  named_scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

  #has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  #validates_as_attachment
  has_attached_file :imported_resource, :path => ":rails_root/private:url"
  validates_attachment_content_type :imported_resource, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
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
    file = File.open(self.imported_resource.path)
    reader = CSV::Reader.create(file, "\t")
    #reader = CSV::Reader.create(NKF.nkf("-w", self.db_file.data), "\t")
    header = reader.shift
    num = {:found => 0, :success => 0, :failure => 0}
    record = 2
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      data.each_value{|v| v.chomp!.to_s}
      library = Library.find(:first, :conditions => {:name => data['library_short_name']}) || Library.web
      shelf = Shelf.find(:first, :conditions => {:name => data['shelf_name']}) || Shelf.web

      # ISBNが入力してあればそれを優先する
      if data['isbn']
        manifestation = Manifestation.find_by_isbn(data['isbn'])
        if manifestation
          num[:found] += 1
        else
          manifestation = Manifestation.import_isbn(data['isbn']) rescue nil
          num[:success] += 1 if manifestation
        end
      end

      ImportedResourceFile.transaction do
        if manifestation.nil?
          begin
            authors = data['author'].split
            publishers = data['publisher'].split
            author_patrons = Manifestation.import_patrons(authors)
            publisher_patrons = Manifestation.import_patrons(publishers)

            work = Work.new
            work.restrain_indexing = true
            work.original_title = data['title']
            if work.save!
              work.patrons << author_patrons
              imported_object = ImportedObject.new
              imported_object.importable = work
              self.imported_objects << imported_object
            end

            expression = Expression.new
            expression.restrain_indexing = true
            expression.original_title = work.original_title
            expression.work = work
            if expression.save!
              imported_object = ImportedObject.new
              imported_object.importable = expression
              self.imported_objects << imported_object
            end

            manifestation = Manifestation.new
            manifestation.restrain_indexing = true
            manifestation.original_title = expression.original_title
            manifestation.expressions << expression
            if manifestation.save!
              manifestation.patrons << author_patrons
              imported_object= ImportedObject.new
              imported_object.importable = manifestation
              self.imported_objects << imported_object
            end
          rescue
            Rails.logger.info("resource import failed: column #{record}")
            num[:failure] += 1
          end
        end

        begin
          item = Item.new
          item.restrain_indexing = true
          item.item_identifier = data['item_identifier']
          item.shelf = shelf
          item.manifestation = manifestation
          if item.save!
            item.patrons << library.patron
            imported_object= ImportedObject.new
            imported_object.importable = item
            self.imported_objects << imported_object
            num[:success] += 1
          end
        rescue
          Rails.logger.info("resource registration failed: column #{record}")
        end
        GC.start if record % 50 == 0
      end
      record += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    file.close
    return num
  end

  def import_marc(marc_type)
    file = File.open(self.imported_resource.path)
    case marc_type
    when 'marcxml'
      reader = MARC::XMLReader.new(file)
    else
      reader = MARC::Reader.new(file)
    end
    file.close

    # when 'marc_xml_url'
    #  url = URI(params[:marc_xml_url])
    #  xml = open(url).read
    #  reader = MARC::XMLReader.new(StringIO.new(xml))
    #end

    # TODO
    for record in reader
      work = Work.new(:title => record['245']['a'])
      work.restrain_indexing = true
      work.work_form = WorkForm.find(1)
      work.save

      expression = Expression.new(:title => work.original_title)
      expression.restrain_indexing = true
      expression.expression_form = ExpressionForm.find(1)
      expression.language = Language.find(1)
      expression.frequency_of_issue = FrequencyOfIssue.find(1)
      expression.save
      work.expressions << expression

      manifestation = Manifestation.new(:title => expression.original_title)
      manifestation.restrain_indexing = true
      manifestation.manifestation_form = ManifestationForm.find(1)
      manifestation.language = Language.find(1)
      manifestation.save
      expression.manifestations << manifestation

      full_name = record['700']['a']
      publisher = Patron.find_by_full_name(record['700']['a'])
      if publisher.blank?
        publisher = Patron.new(:full_name => full_name)
        publisher.restrain_indexing = true
        publisher.save
      end
      manifestation.patrons << publisher
    end
  end

  def self.import
    ImportedResourceFile.not_imported.each do |file|
      file.import
    end
  rescue
    logger.info "#{Time.zone.now} importing resources failed!"
  end

  #def import_jpmarc
  #  marc = NKF::nkf('-wc', self.db_file.data)
  #  marc.split("\r\n").each do |record|
  #  end
  #end

end
