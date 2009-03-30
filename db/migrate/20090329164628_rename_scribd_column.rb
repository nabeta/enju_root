class RenameScribdColumn < ActiveRecord::Migration
  def self.up
    rename_column :attachment_files, :scribd_id, :ipaper_id
    rename_column :attachment_files, :scribd_access_key, :ipaper_access_key
  end

  def self.down
    rename_column :attachment_files, :ipaper_id, :scribd_id
    rename_column :attachment_files, :ipaper_access_key, :scribd_access_key
  end
end
