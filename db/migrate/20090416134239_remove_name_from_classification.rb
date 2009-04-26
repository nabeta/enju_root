class RemoveNameFromClassification < ActiveRecord::Migration
  def self.up
    remove_column :classifications, :name
  end

  def self.down
    add_column :classifications, :name, :string
  end
end
