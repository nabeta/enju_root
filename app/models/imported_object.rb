class ImportedObject < ActiveRecord::Base
  include OnlyLibrarianCanModify
  named_scope :items, :conditions => ['importable_type = ?', 'Item']
  named_scope :manifestations, :conditions => ['importable_type = ?', 'Manifestation']
  named_scope :patrons, :conditions => ['importable_type = ?', 'Patron']
  named_scope :events, :conditions => ['importable_type = ?', 'Event']

  belongs_to :importable, :polymorphic => true #, :validate => true
  belongs_to :imported_file, :polymorphic => true #, :validate => true

  validates_associated :importable, :imported_file
  validates_presence_of :importable, :imported_file

end
