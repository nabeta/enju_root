class PictureFile < ActiveRecord::Base
  scope :attached, where('picture_attachable_id > 0')
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  if configatron.uploaded_file.storage == :s3
    has_attached_file :picture, :storage => :s3, :styles => { :medium => "600x600>", :thumb => "100x100>" },
      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml", :path => "picture_files/:id/:filename"
  else
    has_attached_file :picture, :styles => { :medium => "600x600>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  end
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => ["image/jpeg", "image/pjpeg", "image/png", "image/gif", "image/svg+xml"], :on => :create

  validates :picture_attachable_type, :presence => true, :inclusion => {:in => ['Event', 'Manifestation', 'Patron', 'Shelf']}
  validates_associated :picture_attachable
  default_scope :order => 'position'
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list :scope => 'picture_attachable_type=\'#{picture_attachable_type}\''
  normalize_attributes :picture_attachable_type

  def self.per_page
    10
  end

  def extname
    ext = picture.content_type.split('/')[1].gsub('+xml', '') if picture.content_type
    if ext == 'pjpeg'
      ext = 'jpeg'
    else
      ext
    end
  end

  def content_type
    FileWrapper.get_mime(picture.path) rescue nil
  end
end
