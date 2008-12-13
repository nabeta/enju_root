class CreateCheckoutStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :checkout_stat_has_manifestations do |t|
      t.integer :checkout_stat_id
      t.integer :manifestation_id
      t.integer :checkouts_count

      t.timestamps
    end
    add_index :checkout_stat_has_manifestations, :checkout_stat_id
    add_index :checkout_stat_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :checkout_stat_has_manifestations
  end
end
