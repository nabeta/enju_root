class AddLineToImportedObject < ActiveRecord::Migration
  def self.up
    add_column :imported_objects, :line_number, :integer
  end

  def self.down
    remove_column :imported_objects, :line_number
  end
end
