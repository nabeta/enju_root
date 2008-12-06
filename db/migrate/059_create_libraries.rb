class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.column :patron_id, :integer
      t.column :name, :text, :null => false
      t.column :short_name, :string, :null => false
      t.column :short_display_name, :string, :null => false
      t.column :address, :text
      t.column :telephone_number_1, :string
      t.column :telephone_number_2, :string
      t.column :fax_number, :string
      t.column :lat, :float
      t.column :lng, :float
      t.column :note, :text
      t.column :call_number_rows, :integer, :default => 1, :null => false
      t.string :call_number_delimiter, :default => "|", :null => false
      t.column :library_group_id, :integer, :default => 1, :null => false
      t.integer :users_count, :default => 0, :null => false
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
    add_index :libraries, :patron_id, :unique => true
    add_index :libraries, :library_group_id
    add_index :libraries, :short_name, :unique => true
  end

  def self.down
    drop_table :libraries
  end
end
