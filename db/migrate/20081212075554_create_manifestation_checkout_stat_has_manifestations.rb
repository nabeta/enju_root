class CreateManifestationCheckoutStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestation_checkout_stat_has_manifestations do |t|
      t.integer :manifestation_checkout_stat_id
      t.integer :manifestation_id
      t.integer :checkouts_count

      t.timestamps
    end
    add_index :manifestation_checkout_stat_has_manifestations, :manifestation_checkout_stat_id, :name => 'index_manifestation_checkout_stat_has_m_checkout_id'
    add_index :manifestation_checkout_stat_has_manifestations, :manifestation_id, :name => 'index_manifestation_checkout_stat_has_m_id'
  end

  def self.down
    drop_table :manifestation_checkout_stat_has_manifestations
  end
end
