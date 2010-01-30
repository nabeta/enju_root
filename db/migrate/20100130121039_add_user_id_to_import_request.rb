class AddUserIdToImportRequest < ActiveRecord::Migration
  def self.up
    add_column :import_requests, :user_id, :integer, :null => false
    add_index :import_requests, :user_id
  end

  def self.down
    remove_column :import_requests, :user_id
  end
end
