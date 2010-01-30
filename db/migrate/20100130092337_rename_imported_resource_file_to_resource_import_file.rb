class RenameImportedResourceFileToResourceImportFile < ActiveRecord::Migration
  def self.up
    rename_table :imported_resource_files, :resource_import_files
    rename_table :imported_event_files, :event_import_files
    rename_table :imported_patron_files, :patron_import_files
    rename_column :resource_import_files, :imported_resource_file_name, :resource_import_file_name
    rename_column :resource_import_files, :imported_resource_content_type, :resource_import_content_type
    rename_column :resource_import_files, :imported_resource_file_size, :resource_import_file_size
    rename_column :resource_import_files, :imported_resource_updated_at, :resource_import_updated_at
    rename_column :event_import_files, :imported_event_file_name, :event_import_file_name
    rename_column :event_import_files, :imported_event_content_type, :event_import_content_type
    rename_column :event_import_files, :imported_event_file_size, :event_import_file_size
    rename_column :event_import_files, :imported_event_updated_at, :event_import_updated_at
    rename_column :patron_import_files, :imported_patron_file_name, :patron_import_file_name
    rename_column :patron_import_files, :imported_patron_content_type, :patron_import_content_type
    rename_column :patron_import_files, :imported_patron_file_size, :patron_import_file_size
    rename_column :patron_import_files, :imported_patron_updated_at, :patron_import_updated_at
  end

  def self.down
    rename_column :resource_import_files, :resource_import_file_name, :imported_resource_file_name
    rename_column :resource_import_files, :resource_import_content_type, :imported_resource_content_type
    rename_column :resource_import_files, :resource_import_file_size, :imported_patron_file_size
    rename_column :resource_import_files, :resource_import_updated_at, :imported_resource_updated_at
    rename_column :event_import_files, :event_import_file_name, :imported_event_file_name
    rename_column :event_import_files, :event_import_content_type, :imported_event_content_type
    rename_column :event_import_files, :event_import_file_size, :imported_event_file_size
    rename_column :event_import_files, :event_import_updated_at, :imported_event_updated_at
    rename_column :patron_import_files, :patron_import_file_name, :imported_patron_file_name
    rename_column :patron_import_files, :patron_import_content_type, :imported_patron_content_type
    rename_column :patron_import_files, :patron_import_file_size, :imported_patron_file_size
    rename_column :patron_import_files, :patron_import_updated_at, :imported_patron_updated_at
    rename_table :resource_import_files, :imported_resource_files
    rename_table :event_import_files, :imported_event_files
    rename_table :patron_import_files, :imported_patron_files
  end
end
