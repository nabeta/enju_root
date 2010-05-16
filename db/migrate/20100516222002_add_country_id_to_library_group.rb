class AddCountryIdToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :country_id, :integer
  end

  def self.down
    remove_column :library_groups, :country_id
  end
end
