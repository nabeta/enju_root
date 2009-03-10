class ImportedPatronFile < ActiveRecord::Base
  include LibrarianRequired
  named_scope :not_imported, :conditions => {:imported_at => nil}

  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :importable, :dependent => :destroy
  has_one :imported_object, :as => :imported_file, :dependent => :destroy

  validates_associated :user
  validates_presence_of :user

  def import
    self.reload
    reader = CSV::Reader.create(NKF.nkf("-w", self.db_file.data), "\t")
    header = reader.shift
    num = {:success => 0, :failure => 0, :activated => 0}
    record = 2
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      data.each_value{|v| v.chomp!.to_s}
      begin
        patron = Patron.new
        patron.first_name = data['first_name']
        patron.middle_name = data['middle_name']
        patron.last_name = data['last_name']
        patron.first_name_transcription = data['first_name_transcription']
        patron.middle_name_transcription = data['middle_name_transcription']
        patron.last_name_transcription = data['last_name_transcription']

        patron.full_name = data['full_name']
        patron.full_name_transcription = data['full_name_transcription']
        patron.full_name = data['last_name'] + data['middle_name'] + data['first_name'] if patron.full_name.blank?

        patron.address_1 = data['address_1']
        patron.address_2 = data['address_2']
        patron.zip_code_1 = data['zip_code_1']
        patron.zip_code_2 = data['zip_code_2']
        patron.telephone_number_1 = data['telephone_number_1']
        patron.telephone_number_2 = data['telephone_number_2']
        patron.fax_number_1 = data['fax_number_1']
        patron.fax_number_2 = data['fax_number_2']
        patron.note = data['note']
        country = Country.find_by_name(data['country'])
        patron.country = country if country.present?

        if patron.save!
          imported_object = ImportedObject.new
          imported_object.importable = patron
          imported_object.imported_file = self
          imported_object.save
          num[:success] += 1
          GC.start if num[:success] % 50 == 0
        end
      rescue
        Rails.logger.info("patron import failed: column #{record}")
        num[:failure] += 1
      end

      unless data['login'].blank?
        begin
          user = User.new
          user.login =  data['login'].to_s.chomp
          user.email = data['email'].to_s.chomp
          user.password = data['password'].to_s.chomp
          user.password_confirmation = data['password'].to_s.chomp
          library = Library.find(:first, :conditions => {:short_name => data['library_short_name'].to_s.chomp})
          library = Library.web if library.blank?
          user.library = library
          user.patron = patron
          user.save!
          num[:activated] += 1
        rescue
          Rails.logger.info("user import failed: column #{record}")
        end
      end

      record += 1
    end
    return num
  end
end
