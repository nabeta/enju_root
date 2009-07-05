class AddDisplayNameToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :display_name, :text
    remove_column :libraries, :name
    rename_column :libraries, :short_name, :name
  end

  def self.down
    remove_column :libraries, :display_name
    rename_column :libraries, :name, :short_name
    add_column :libraries, :name, :string
  end
end
