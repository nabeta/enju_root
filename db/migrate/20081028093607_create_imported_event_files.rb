class CreateImportedEventFiles < ActiveRecord::Migration
  def self.up
    create_table :imported_event_files do |t|
      t.integer :db_file_id
      t.integer :parent_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.string :file_hash
      t.integer :user_id
      t.text :note
      t.datetime :imported_at

      t.timestamps
    end
    add_index :imported_event_files, :db_file_id
    add_index :imported_event_files, :parent_id
    add_index :imported_event_files, :user_id
    add_index :imported_event_files, :file_hash
  end

  def self.down
    drop_table :imported_event_files
  end
end
