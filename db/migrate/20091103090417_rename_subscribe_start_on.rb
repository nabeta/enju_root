class RenameSubscribeStartOn < ActiveRecord::Migration
  def self.up
    rename_column :subscribes, :start_on, :started_on
    rename_column :subscribes, :end_on, :ended_on
  end

  def self.down
    rename_column :subscribes, :started_on, :start_on
    rename_column :subscribes, :ended_on, :end_on
  end
end
