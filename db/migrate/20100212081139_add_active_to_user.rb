class AddActiveToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean #, :null => false
    change_column_default :users, :active, false
  end

  def self.down
    remove_column :users, :active
  end
end
