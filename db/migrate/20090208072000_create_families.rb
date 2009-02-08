class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.integer :parent_id
      t.string :name
      t.string :name_transcription
      t.text :name_alternative
      t.timestamps
      t.datetime :deleted_at
      t.string :zip_code_1
      t.string :zip_code_2
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
      t.integer :access_role_id, :null => false
      t.integer :required_score, :default => 0, :null => false
      t.string :state
    end
    add_index :families, :parent_id
    add_index :families, :language_id
    add_index :families, :country_id
    add_index :families, :access_role_id
    add_index :families, :name
  end

  def self.down
    drop_table :families
  end
end
