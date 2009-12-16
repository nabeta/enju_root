class AddParentOfSeriesToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :parent_of_series, :boolean
  end

  def self.down
    remove_column :works, :parent_of_series
  end
end
