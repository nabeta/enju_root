class AttachmentFile < ActiveRecord::Base
  include LibrarianRequired
  #include ExtractContent
  belongs_to :attachable, :polymorphic => true, :validate => true
  has_one :db_file

  named_scope :pictures, :conditions => {:content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png']}

  has_attachment
  validates_as_attachment
  validates_associated :attachable
  #alidates_presence_of :attachable_id, :attachable_type

  cattr_accessor :per_page
  @@per_page = 10
  
  before_save :extract_text
  #after_save :save_manifestation
  #after_destroy :save_manifestation

  def create_resource(title)
    AttachmentFile.transaction do
      work = Work.create!(:original_title => title)
      expression = Expression.new(:original_title => title)
      work.expressions << expression
      manifestation = Manifestation.new(:original_title => title)
      manifestation.manifestation_form = ManifestationForm.find_by_name('file')
      expression.manifestations << manifestation
      self.attachable = manifestation
    end
  end

  #def save_manifestation
  #  if self.attachable_type == 'Manifestation'
  #    manifestation = Manifestation.find(self.attachable_id)
  #    manifestation.save
  #  end
  #rescue
  #  nil
  #end

  def extract_text
    content = Tempfile::new("content")
    content.puts(self.db_file.data)
    content.close
    fulltext = Tempfile::new("fulltext")
    case self.content_type
    when "application/pdf"
      system("pdftotext -q -enc UTF-8 -raw #{content.path} #{fulltext.path}")
    when "application/msword"
      system("antiword #{content.path} 2> /dev/null > #{fulltext.path}")
    when "application/vnd.ms-excel"
      system("xlhtml #{content.path} 2> /dev/null > #{fulltext.path}")
    when "application/vnd.ms-powerpoint"
      system("ppthtml #{content.path} 2> /dev/null #{fulltext.path}")
#    when "text/html"
#      system("elinks --dump 1 #{self.full_filename} 2> /dev/null #{temp.path}")
    #  html = open(self.full_filename).read
    #  body, title = ExtractContent::analyse(html)
    #  body = NKF.nkf('-w', body)
    #  title = NKF.nkf('-w', title)
    #  temp.open
    #  temp.puts(title)
    #  temp.puts(body)
    #  temp.close
    #else
    #  nil
    end

    self.update_attribute(:fulltext, fulltext.read)
    fulltext.close
  rescue
    nil
  end

  def digest(options = {:type => 'sha1'})
    if self.file_hash.blank?
      self.file_hash = Digest::SHA1.hexdigest(self.db_file.data)
    end
    self.file_hash
  end

end
