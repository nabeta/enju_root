class CreateAttachmentFiles < ActiveRecord::Migration
  def self.up
    create_table :attachment_files do |t|
      t.integer :attachable_id
      t.string :attachable_type
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

      t.timestamps
    end
    add_index :attachment_files, [:attachable_id, :attachable_type], :name => "index_attachment_files_on_attachment_file_id_and_type"
    add_index :attachment_files, :parent_id
    add_index :attachment_files, :db_file_id
    add_index :attachment_files, :file_hash
  end

  def self.down
    drop_table :attachment_files
  end
end
