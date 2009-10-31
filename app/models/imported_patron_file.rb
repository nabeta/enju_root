class ImportedPatronFile < ActiveRecord::Base
  include AASM
  include LibrarianRequired
  named_scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

  #has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  #validates_as_attachment
  has_attached_file :imported_patron, :path => ":rails_root/private:url"
  validates_attachment_content_type :imported_patron, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
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
    file = File.open(self.imported_patron.path)
    reader = CSV::Reader.create(file, "\t")
    #reader = CSV::Reader.create(NKF.nkf("-w", self.db_file.data), "\t")
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
          self.imported_objects << imported_object
          num[:success] += 1
          GC.start if record % 50 == 0
        end
      rescue
        Rails.logger.info("patron import failed: column #{record}")
        num[:failure] += 1
      end

      unless data['login'].blank?
        begin
          user = User.new(
            :login => data['login'].to_s.chomp,
            :email => data['email'].to_s.chomp,
            :user_number => data['user_number'].to_s.chomp,
            :password => data['password'].to_s.chomp,
            :password_confirmation => data['password'].to_s.chomp
          )
          if user.password.blank?
            user.set_auto_generated_password
          end
          library = Library.find(:first, :conditions => {:name => data['library_short_name'].to_s.chomp}) || Library.web
          user_group = UserGroup.find(:first, :conditions => {:name => data['user_group_name']}) || UserGroup.first
          user.library = library
          user.patron = patron
          user.save!
          role = Role.find(:first, :conditions => {:name => data['role']}) || Role.find(2)
          user.roles << role
          num[:activated] += 1
        rescue
          Rails.logger.info("user import failed: column #{record}")
        end
      end

      record += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    file.close
    return num
  end

  def self.import
    ImportedPatronFile.not_imported.each do |file|
      file.aasm_import!
    end
  rescue
    logger.info "#{Time.zone.now} importing patrons failed!"
  end
end
