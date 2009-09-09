class Classification < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :subject_has_classifications, :dependent => :destroy
  has_many :subjects, :through => :subject_has_classifications
  belongs_to :classification_type, :validate => true
  #has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :subject_has_classifications

  validates_associated :classification_type
  validates_presence_of :category, :classification_type_id
  validates_uniqueness_of :category, :scope => :classification_type_id
  searchable :auto_index => false do
    text :category, :note, :subject
    integer :subject_ids, :multiple => true
    integer :classification_type_id
  end
  acts_as_tree
  #acts_as_taggable_on :tags

  cattr_accessor :per_page
  @@per_page = 10

  def subject
    self.subjects.collect(&:term) + self.subjects.collect(&:term_transcription)
  end

  def after_save
    send_later(:index!)
  end

  def after_destroy
    send_later(:remove_from_index!)
  end
end
