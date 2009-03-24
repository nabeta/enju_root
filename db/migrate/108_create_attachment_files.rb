class CreateAttachmentFiles < ActiveRecord::Migration
  def self.up
    create_table :attachment_files do |t|
      t.integer :manifestation_id
      t.integer :size
      t.string :content_type
      t.text :title
      t.text :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
      t.integer :db_file_id
      t.text :fulltext
      t.string :file_hash
      t.datetime :indexed_at

      t.timestamps
    end
    add_index :attachment_files, :manifestation_id
    add_index :attachment_files, :parent_id
    add_index :attachment_files, :db_file_id
    add_index :attachment_files, :file_hash
  end

  def self.down
    drop_table :attachment_files
  end
end
