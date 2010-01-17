class RenameSubscribeManifestationIdToWorkId < ActiveRecord::Migration
  def self.up
    rename_column :subscribes, :manifestation_id, :work_id
  end

  def self.down
    rename_column :subscribes, :work_id, :manifestation_id
  end
end
