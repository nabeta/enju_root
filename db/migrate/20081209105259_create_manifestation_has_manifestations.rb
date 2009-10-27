class CreateManifestationHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestation_has_manifestations do |t|
      t.integer :from_manifestation_id, :null => false
      t.integer :to_manifestation_id, :null => false
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :manifestation_has_manifestations, :from_manifestation_id
    add_index :manifestation_has_manifestations, :to_manifestation_id
    add_index :manifestation_has_manifestations, :type
  end

  def self.down
    drop_table :manifestation_has_manifestations
  end
end
