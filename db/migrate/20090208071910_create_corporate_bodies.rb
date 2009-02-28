class CreateCorporateBodies < ActiveRecord::Migration
  def self.up
    create_table :corporate_bodies do |t|
      t.integer :parent_id
      t.string :full_name
      t.text :full_name_transcription
      t.text :full_name_alternative
      t.timestamps
      t.datetime :deleted_at
      t.string :postal_code_1
      t.string :postal_code_2
      t.text :address_1
      t.text :address_2
      t.text :address_1_note
      t.text :address_2_note
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number_1
      t.string :fax_number_2
      t.text :other_designation
      t.text :place
      t.datetime :date_of_birth
      t.datetime :date_of_death
      t.integer :language_id, :default => 1, :null => false
      t.integer :country_id, :default => 1, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.text :note
      t.integer :creates_count, :default => 0, :null => false
      t.integer :realizes_count, :default => 0, :null => false
      t.integer :produces_count, :default => 0, :null => false
      t.integer :owns_count, :default => 0, :null => false
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.integer :required_score, :default => 0, :null => false
      t.string :state
    end
    add_index :corporate_bodies, :parent_id
    add_index :corporate_bodies, :language_id
    add_index :corporate_bodies, :country_id
    add_index :corporate_bodies, :required_role_id
    add_index :corporate_bodies, :full_name
  end

  def self.down
    drop_table :corporate_bodies
  end
end
