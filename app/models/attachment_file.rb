class AttachmentFile < ActiveRecord::Base
  include LibrarianRequired
  named_scope :not_indexed, :conditions => ['indexed_at IS NULL']
  belongs_to :manifestation
  #has_one :db_file

  named_scope :pictures, :conditions => {:content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png']}
  default_scope :order => 'id DESC'

  has_attachment :storage => :file_system
  validates_as_attachment
  validates_presence_of :manifestation
  validates_associated :manifestation

  has_ipaper_and_uses 'AttachmentFu'
  enju_scribd

  cattr_accessor :per_page
  @@per_page = 10
  attr_accessor :title, :post_to_twitter
  
  #before_save :extract_text

  def before_validation_on_create
    unless self.manifestation
      manifestation = Manifestation.create!(:original_title => self.title, :manifestation_form => ManifestationForm.find(:first, :conditions => {:name => 'file'}), :post_to_twitter => self.post_to_twitter, :restrain_indexing => true)
      self.manifestation_id = manifestation.id
    end
  end

  def extract_text
    extractor = ExtractContent::Extractor.new
    content = Tempfile::new("content")
    content.puts(self.db_file.data)
    content.close
    text = Tempfile::new("text")
    case self.content_type
    when "application/pdf"
      system("pdftotext -q -enc UTF-8 -raw #{content.path} #{text.path}")
      self.fulltext = text.read
    when "application/msword"
      system("antiword #{content.path} 2> /dev/null > #{text.path}")
      self.fulltext = text.read
    when "application/vnd.ms-excel"
      system("xlhtml #{content.path} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "application/vnd.ms-powerpoint"
      system("ppthtml #{content.path} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "text/html"
      # TODO: 日本語以外
      system("elinks --dump 1 #{self.full_filename} 2> /dev/null | nkf -w > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    end

    self.indexed_at = Time.zone.now
    self.save
    text.close
  end

  def self.extract_text
    AttachmentFile.not_indexed.find_each do |file|
      file.extract_text
    end
  end

  def digest(options = {:type => 'sha1'})
    if self.file_hash.blank?
      #self.file_hash = Digest::SHA1.hexdigest(self.db_file.data)
      self.file_hash = Digest::SHA1.hexdigest(open(self.file_path).read)
    end
    self.file_hash
  end

end
