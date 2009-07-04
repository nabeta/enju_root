class CreateShelfHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :shelf_has_manifestations do |t|
      t.integer :shelf_id
      t.integer :manifestation_id
      t.integer :position

      t.timestamps
    end
    add_index :shelf_has_manifestations, :shelf_id
    add_index :shelf_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :shelf_has_manifestations
  end
end
