class AddCountryToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :country_id, :integer
  end

  def self.down
    remove_column :libraries, :country_id
  end
end
