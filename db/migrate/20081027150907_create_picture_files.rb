class CreatePictureFiles < ActiveRecord::Migration
  def self.up
    create_table :picture_files do |t|
      t.integer :picture_attachable_id
      t.string :picture_attachable_type
      t.integer :size
      t.string :content_type
      t.text :title
      t.text :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
      t.integer :db_file_id
      t.string :file_hash

      t.timestamps
    end
    add_index :picture_files, [:picture_attachable_id, :picture_attachable_type], :name => "index_picture_files_on_picture_attachable_id_and_type"
    add_index :picture_files, :parent_id
    add_index :picture_files, :db_file_id
  end

  def self.down
    drop_table :picture_files
  end
end
