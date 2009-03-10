class AddDsblListToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :dsbl_list, :text
  end

  def self.down
    add_column :library_groups, :use_dsbl, :boolean
  end
end
