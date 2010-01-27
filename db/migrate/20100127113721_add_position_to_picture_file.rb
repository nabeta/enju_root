class AddPositionToPictureFile < ActiveRecord::Migration
  def self.up
    add_column :picture_files, :position, :integer
  end

  def self.down
    remove_column :picture_files, :position
  end
end
