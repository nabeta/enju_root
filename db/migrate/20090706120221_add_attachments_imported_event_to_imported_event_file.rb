class AddAttachmentsImportedEventToImportedEventFile < ActiveRecord::Migration
  def self.up
    add_column :imported_event_files, :imported_event_file_name, :string
    add_column :imported_event_files, :imported_event_content_type, :string
    add_column :imported_event_files, :imported_event_file_size, :integer
    add_column :imported_event_files, :imported_event_updated_at, :datetime
  end

  def self.down
    remove_column :imported_event_files, :imported_event_file_name
    remove_column :imported_event_files, :imported_event_content_type
    remove_column :imported_event_files, :imported_event_file_size
    remove_column :imported_event_files, :imported_event_updated_at
  end
end
