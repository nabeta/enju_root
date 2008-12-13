class CreateLibraryGroups < ActiveRecord::Migration
  def self.up
    create_table :library_groups do |t|
      t.column :name, :text, :null => false
      t.column :display_name, :string
      t.column :short_name, :string, :null => false
      t.column :email, :string
      t.text :my_networks
      t.boolean :use_dsbl, :default => false, :null => false
      t.text :note
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :library_groups, :short_name
  end

  def self.down
    drop_table :library_groups
  end
end
