class AddDisplayNameToShelf < ActiveRecord::Migration
  def self.up
    add_column :shelves, :display_name, :string
  end

  def self.down
    remove_column :shelves, :display_name
  end
end
