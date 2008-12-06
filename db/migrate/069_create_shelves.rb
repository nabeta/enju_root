class CreateShelves < ActiveRecord::Migration
  def self.up
    create_table :shelves do |t|
      t.column :name, :string
      t.column :note, :text
      t.column :library_id, :integer, :default => 1, :null => false
      t.column :items_count, :integer, :default => 0, :null => false
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
    add_index :shelves, :library_id
  end

  def self.down
    drop_table :shelves
  end
end
