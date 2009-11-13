class RenameEventDate < ActiveRecord::Migration
  def self.up
    rename_column :events, :started_at, :start_at
    rename_column :events, :ended_at, :end_at
  end

  def self.down
    rename_column :events, :start_at, :started_at
    rename_column :events, :end_at, :ended_at
  end
end
