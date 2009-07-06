class PictureFile < ActiveRecord::Base
  include OnlyLibrarianCanModify
  named_scope :attached, :conditions => ['picture_attachable_id > 0']
  belongs_to :picture_attachable, :polymorphic => true, :validate => true
  #belongs_to :db_file

  #has_attachment :content_type => :image, #:resize_to => [800,800],
  #  :thumbnails => { :geometry => 'x400' }
  #validates_as_attachment
  has_attached_file :picture, :styles => { :medium => "500x500>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => %r{image/.*}

  validates_associated :picture_attachable
  validates_presence_of :picture_attachable_id, :picture_attachable_type #, :unless => :parent_id, :on => :create
  default_scope :order => 'id DESC'

  cattr_accessor :per_page
  @@per_page = 10

  def after_save
    send_later(:set_digest)
  end

  def set_digest(options = {:type => 'sha1'})
    file_hash = Digest::SHA1.hexdigest(self.picture.path)
    save(false)
  end

  def extname
    File.extname(picture_file_name).gsub(/^\./, '') rescue nil
  end
end
