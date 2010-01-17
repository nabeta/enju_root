class ChangeSubscribeDate < ActiveRecord::Migration
  def self.up
    change_column :subscribes, :started_on, :timestamp
    change_column :subscribes, :ended_on, :timestamp
    rename_column :subscribes, :started_on, :start_at
    rename_column :subscribes, :ended_on, :end_at
  end

  def self.down
    rename_column :subscribes, :start_at, :started_on
    rename_column :subscribes, :end_at, :ended_on
    change_column :subscribes, :started_on, :date
    change_column :subscribes, :ended_on, :date
  end
end
