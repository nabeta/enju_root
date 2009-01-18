class CreateLibraryGroups < ActiveRecord::Migration
  def self.up
    create_table :library_groups do |t|
      t.string :name, :null => false
      t.string :display_name
      t.string :short_name, :null => false
      t.string :email
      t.text :my_networks
      t.boolean :use_dsbl, :default => false, :null => false
      t.text :note
      t.timestamps
    end
    add_index :library_groups, :short_name
  end

  def self.down
    drop_table :library_groups
  end
end
