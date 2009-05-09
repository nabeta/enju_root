class AddDisplayNameToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :display_name, :text
    remove_column :libraries, :name
    rename_column :libraries, :short_name, :name
  end

  def self.down
    remove_column :libraries, :display_name
    add_column :libraries, :name, :string
    rename_column :libraries, :name, :short_name
  end
end
