class PictureFile < ActiveRecord::Base
  include OnlyLibrarianCanModify
  named_scope :attached, :conditions => ['picture_attachable_id > 0']
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  #has_attachment :content_type => :image, #:resize_to => [800,800],
  #  :thumbnails => { :geometry => 'x400' }
  #validates_as_attachment
  has_attached_file :picture, :styles => { :medium => "500x500>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => %r{image/.*}

  validates_associated :picture_attachable
  validates_presence_of :picture_attachable_id, :picture_attachable_type #, :unless => :parent_id, :on => :create
  default_scope :order => 'position'
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list :scope => 'picture_attachable_id=#{picture_attachable_id} AND picture_attachable_type=\'#{picture_attachable_type}\''

  def self.per_page
    10
  end

  def after_create
    send_later(:set_digest) if self.picture.path
  end

  def set_digest(options = {:type => 'sha1'})
    file_hash = Digest::SHA1.hexdigest(File.open(self.picture.path, 'rb').read)
    save(false)
  end

  def extname
    content_type.split('/')[1] if content_type
  end

  def content_type
    FileWrapper.get_mime(picture.path) rescue nil
  end
end
