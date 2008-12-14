class CreateManifestationHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestation_has_manifestations do |t|
      t.integer :from_manifestation_id
      t.integer :to_manifestation_id
      t.integer :manifestation_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :manifestation_has_manifestations, :from_manifestation_id
    add_index :manifestation_has_manifestations, :to_manifestation_id
    add_index :manifestation_has_manifestations, :manifestation_relationship_type_id, :name => 'index_manifestation_has_manifestations_on_r_type_id'
  end

  def self.down
    drop_table :manifestation_has_manifestations
  end
end
