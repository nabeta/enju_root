class AddAttachmentsImportedPatronToImportedPatronFile < ActiveRecord::Migration
  def self.up
    add_column :imported_patron_files, :imported_patron_file_name, :string
    add_column :imported_patron_files, :imported_patron_content_type, :string
    add_column :imported_patron_files, :imported_patron_file_size, :integer
    add_column :imported_patron_files, :imported_patron_updated_at, :datetime
  end

  def self.down
    remove_column :imported_patron_files, :imported_patron_file_name
    remove_column :imported_patron_files, :imported_patron_content_type
    remove_column :imported_patron_files, :imported_patron_file_size
    remove_column :imported_patron_files, :imported_patron_updated_at
  end
end
