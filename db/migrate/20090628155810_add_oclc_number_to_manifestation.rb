class AddOclcNumberToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :oclc_number, :string
  end

  def self.down
    remove_column :manifestations, :oclc_number
  end
end
