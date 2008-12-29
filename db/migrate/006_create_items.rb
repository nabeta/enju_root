class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :parent_id, :integer
      t.column :call_number, :string
      t.column :item_identifier, :string
      t.column :circulation_status_id, :integer, :null => false
      t.column :checkout_type_id, :integer, :default => 1, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
      t.column :shelf_id, :integer, :default => 1, :null => false
      t.column :basket_id, :integer
      t.column :include_supplements, :boolean, :default => false, :null => false
      t.column :checkouts_count, :integer, :default => 0, :null => false
      t.column :owns_count, :integer, :default => 0, :null => false
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :note, :text
      t.column :url, :string
      t.decimal :price
      t.column :lock_version, :integer, :default => 0, :null => false
      t.integer :access_role_id, :default => 1, :null => false
      t.string :state
    end
    add_index :items, :parent_id
    add_index :items, :circulation_status_id
    add_index :items, :checkout_type_id
    add_index :items, :shelf_id
    add_index :items, :item_identifier
    add_index :items, :access_role_id
  end

  def self.down
    drop_table :items
  end
end
