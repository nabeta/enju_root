class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.references :holding_patron, :polymorphic => true
      t.text :name, :null => false
      t.string :short_name, :null => false
      t.string :short_display_name, :null => false
      t.string :zip_code
      t.text :address
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number
      t.float :lat
      t.float :lng
      t.text :note
      t.integer :call_number_rows, :default => 1, :null => false
      t.string :call_number_delimiter, :default => "|", :null => false
      t.integer :library_group_id, :default => 1, :null => false
      t.integer :users_count, :default => 0, :null => false
      t.integer :position

      t.timestamps
      t.datetime :deleted_at
    end
    add_index :libraries, :holding_patron_id, :unique => true
    add_index :libraries, :library_group_id
    add_index :libraries, :short_name, :unique => true
  end

  def self.down
    drop_table :libraries
  end
end
