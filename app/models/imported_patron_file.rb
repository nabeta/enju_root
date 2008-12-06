class ImportedPatronFile < ActiveRecord::Base
  named_scope :not_imported, :conditions => {:imported_at => nil}

  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :importable, :dependent => :destroy

  validates_associated :user
  validates_presence_of :user

  def import
    self.reload
    reader = CSV::Reader.create(NKF.nkf("-w", self.db_file.data), "\t")
    header = reader.shift
    num = {:success => 0, :failure => 0, :activated => 0}
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
      begin
        patron = Patron.new
        patron.full_name = data['full_name'].to_s.chomp
        if patron.save!
          imported_object = ImportedObject.new
          imported_object.importable = patron
          self.imported_objects << imported_object
          num[:success] += 1
          GC.start if num[:success] % 50 == 0
        end
      rescue
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
          library = Library.find(1) if library.blank?
          user.library = library
          user.patron = patron
          user.save!
          num[:activated] += 1
        rescue
          nil
        end
      end

    end
    return num
  end
end
