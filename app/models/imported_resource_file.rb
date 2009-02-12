class ImportedResourceFile < ActiveRecord::Base
  named_scope :not_imported, :conditions => {:imported_at => nil}

  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment
  belongs_to :user
  has_many :imported_objects, :as => :importable, :dependent => :destroy

  def import
    self.reload
    reader = CSV::Reader.create(self.db_file.data, "\t")
    header = reader.shift
    num = 0
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      begin
        library = Library.find(:first, :conditions => {:short_name => data['library_short_name'].chomp})
      rescue
        library = Library.find(1) if library.nil?
      end

      # ISBNが入力してあればそれを優先する
      if data['isbn']
        manifestation = Manifestation.import_isbn(data['isbn']) rescue nil
      end

      if manifestation.nil?
        ImportedResourceFile.transaction do
          begin
            authors = data['author'].split
            publishers = data['publisher'].split
            author_patrons = Manifestation.import_patrons(authors)
            publisher_patrons = Manifestation.import_patrons(publishers)

            work = Work.new
            work.original_title = data['title'].chomp
            if work.save!
              work.patrons << author_patrons
              imported_object= ImportedObject.new
              imported_object.importable = work
              self.imported_objects << imported_object
            end

            expression = Expression.new
            expression.original_title = work.original_title
            expression.work = work
            if expression.save!
              imported_object= ImportedObject.new
              imported_object.importable = expression
              self.imported_objects << imported_object
            end

            manifestation = Manifestation.new
            manifestation.original_title = expression.original_title
            manifestation.expressions << expression
            if manifestation.save!
              manifestation.patrons << author_patrons
              imported_object= ImportedObject.new
              imported_object.importable = manifestation
              self.imported_objects << imported_object
            end

            item = Item.new
            item.manifestation = manifestation
            if item.save!
              item.patrons << library.patron
              imported_object= ImportedObject.new
              imported_object.importable = item
              self.imported_objects << imported_object
            end

            num += 1
            GC.start if num % 50 == 0
          rescue
            nil
          end
        end
      end
    end
    return num
  end

  def import_marc(marc_file, marc_type)
    case marc_type
    when 'marcxml'
      reader = MARC::XMLReader.new(StringIO.new(marc_file.read))
    else
      reader = MARC::Reader.new(StringIO.new(marc_file.read))
    end

    # when 'marc_xml_url'
    #  url = URI(params[:marc_xml_url])
    #  xml = open(url).read
    #  reader = MARC::XMLReader.new(StringIO.new(xml))
    #end

    # TODO
    for record in reader
      work = Work.new(:title => record['245']['a'])
      work.work_form = WorkForm.find(1)
      work.save

      expression = Expression.new(:title => work.original_title)
      expression.expression_form = ExpressionForm.find(1)
      expression.language = Language.find(1)
      expression.frequency_of_issue = FrequencyOfIssue.find(1)
      expression.save
      work.expressions << expression

      manifestation = Manifestation.new(:title => expression.original_title)
      manifestation.manifestation_form = ManifestationForm.find(1)
      manifestation.language = Language.find(1)
      manifestation.save
      expression.manifestations << manifestation

      publisher = Patron.find_by_corporate_name(record['700']['a'])
      manifestation.patrons << publisher
    end
  end

end
