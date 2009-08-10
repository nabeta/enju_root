class AddIssnToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :issn, :string
  end

  def self.down
    remove_column :manifestations, :issn
  end
end
