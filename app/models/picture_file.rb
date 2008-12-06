class PictureFile < ActiveRecord::Base
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  has_attachment :content_type => :image, #:resize_to => [800,800],
    :thumbnails => { :geometry => 'x400' }
  validates_as_attachment

  validates_associated :picture_attachable
  validates_presence_of :picture_attachable_id, :picture_attachable_type, :unless => :parent_id

  cattr_reader :per_page
  @@per_page = 10

  def digest(options = {:type => 'sha1'})
    if self.file_hash.blank?
      self.file_hash = Digest::SHA1.hexdigest(self.db_file.data)
    end
    self.file_hash
  end

  def extname
    File.extname(self.filename).gsub(/^\./, '') rescue nil
  end
end
