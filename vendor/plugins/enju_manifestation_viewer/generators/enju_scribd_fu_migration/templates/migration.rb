class EnjuScribdFuMigration < ActiveRecord::Migration
  def self.up
    add_column :attachment_files, :scribd_id, :integer
    add_column :attachment_files, :scribd_access_key, :string
  end

  def self.down
    remove_column :attachment_files, :scribd_id
    remove_column :attachment_files, :scribd_access_key
  end
end
