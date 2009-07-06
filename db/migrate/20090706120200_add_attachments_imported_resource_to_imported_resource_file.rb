class AddAttachmentsImportedResourceToImportedResourceFile < ActiveRecord::Migration
  def self.up
    add_column :imported_resource_files, :imported_resource_file_name, :string
    add_column :imported_resource_files, :imported_resource_content_type, :string
    add_column :imported_resource_files, :imported_resource_file_size, :integer
    add_column :imported_resource_files, :imported_resource_updated_at, :datetime
  end

  def self.down
    remove_column :imported_resource_files, :imported_resource_file_name
    remove_column :imported_resource_files, :imported_resource_content_type
    remove_column :imported_resource_files, :imported_resource_file_size
    remove_column :imported_resource_files, :imported_resource_updated_at
  end
end
