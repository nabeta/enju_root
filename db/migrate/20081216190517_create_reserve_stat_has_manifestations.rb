class CreateReserveStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :reserve_stat_has_manifestations do |t|
      t.integer :reserve_stat_id
      t.integer :manifestation_id
      t.integer :reserves_count

      t.timestamps
    end
    add_index :reserve_stat_has_manifestations, :reserve_stat_id
    add_index :reserve_stat_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :reserve_stat_has_manifestations
  end
end
