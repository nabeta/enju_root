class PatronImportFile < ActiveRecord::Base
  include AASM
  include LibrarianRequired
  default_scope :order => 'id DESC'
  named_scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

  #has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  #validates_as_attachment
  has_attached_file :patron_import, :path => ":rails_root/private:url"
  validates_attachment_content_type :patron_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :imported_file, :dependent => :destroy

  validates_associated :user
  validates_presence_of :user

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
    num = {:success => 0, :failure => 0, :activated => 0}
    record = 2
    file = FasterCSV.open(self.patron_import.path, :col_sep => "\t")
    rows = FasterCSV.open(self.patron_import.path, :headers => file.first, :col_sep => "\t")
    file.close
    rows.shift
    rows.each do |row|
      begin
        patron = Patron.new
        patron.first_name = row['first_name']
        patron.middle_name = row['middle_name']
        patron.last_name = row['last_name']
        patron.first_name_transcription = row['first_name_transcription']
        patron.middle_name_transcription = row['middle_name_transcription']
        patron.last_name_transcription = row['last_name_transcription']

        patron.full_name = row['full_name']
        patron.full_name_transcription = row['full_name_transcription']
        patron.full_name = row['last_name'] + row['middle_name'] + row['first_name'] if patron.full_name.blank?

        patron.address_1 = row['address_1']
        patron.address_2 = row['address_2']
        patron.zip_code_1 = row['zip_code_1']
        patron.zip_code_2 = row['zip_code_2']
        patron.telephone_number_1 = row['telephone_number_1']
        patron.telephone_number_2 = row['telephone_number_2']
        patron.fax_number_1 = row['fax_number_1']
        patron.fax_number_2 = row['fax_number_2']
        patron.note = row['note']
        country = Country.find_by_name(row['country'])
        patron.country = country if country.present?

        if patron.save!
          imported_object = ImportedObject.new(:line_number => record)
          imported_object.importable = patron
          self.imported_objects << imported_object
          num[:success] += 1
          GC.start if record % 50 == 0
        end
      rescue
        Rails.logger.info("patron import failed: column #{record}")
        num[:failure] += 1
      end

      unless row['login'].blank?
        begin
          user = User.new
          user.login = row['login'].to_s.chomp
          user.email = row['email'].to_s.chomp
          user_number = row['user_number'].to_s.chomp
          user.password = row['password'].to_s.chomp
          user.password_confirmation = row['password'].to_s.chomp
          if user.password.blank?
            user.set_auto_generated_password
          end
          library = Library.first(:conditions => {:name => row['library_short_name'].to_s.chomp}) || Library.web
          user_group = UserGroup.first(:conditions => {:name => row['user_group_name']}) || UserGroup.first
          user.library = library
          user.patron = patron
          user.activate!
          role = Role.first(:conditions => {:name => row['role']}) || Role.find(2)
          user.roles << role
          num[:activated] += 1
        rescue
          Rails.logger.info("user import failed: column #{record}")
        end
      end

      record += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    return num
  end

  def self.import
    PatronImportFile.not_imported.each do |file|
      file.aasm_import!
    end
  rescue
    logger.info "#{Time.zone.now} importing patrons failed!"
  end
end
