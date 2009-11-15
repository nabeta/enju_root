class AddAllDayToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :all_day, :boolean
  end

  def self.down
    remove_column :events, :all_day
  end
end
