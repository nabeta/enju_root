class AddDsblListToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :dsbl_list, :text
  end

  def self.down
    remove_column :library_groups, :dsbl_list
  end
end
