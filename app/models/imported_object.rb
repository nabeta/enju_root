class ImportedObject < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :importable, :polymorphic => true #, :validate => true
  belongs_to :imported_file, :polymorphic => true #, :validate => true

  validates_associated :importable #, :imported_file
  validates_presence_of :importable #, :imported_file
end
