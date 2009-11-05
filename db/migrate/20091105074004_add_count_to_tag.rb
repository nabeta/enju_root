class AddCountToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :count
  end
end
