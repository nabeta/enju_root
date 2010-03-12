class AddActiveToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean #, :null => false
    add_column :users, :confirmed, :boolean #, :null => false
    add_column :users, :approved, :boolean #, :null => false
    change_column_default :users, :active, false
    change_column_default :users, :confirmed, false
    change_column_default :users, :approved, false
  end

  def self.down
    remove_column :users, :active
    remove_column :users, :confirmed
    remove_column :users, :approved
  end
end
