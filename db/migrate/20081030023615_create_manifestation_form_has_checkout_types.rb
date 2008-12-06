class CreateManifestationFormHasCheckoutTypes < ActiveRecord::Migration
  def self.up
    create_table :manifestation_form_has_checkout_types do |t|
      t.integer :manifestation_form_id, :null => false
      t.integer :checkout_type_id, :null => false
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :manifestation_form_has_checkout_types, :manifestation_form_id, :name => 'index_manifestation_form_has_checkout_types_on_m_form_id'
    add_index :manifestation_form_has_checkout_types, :checkout_type_id
  end

  def self.down
    drop_table :manifestation_form_has_checkout_types
  end
end
