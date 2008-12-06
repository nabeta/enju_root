class CreatePatrons < ActiveRecord::Migration
  def self.up
    create_table :patrons do |t|
      t.column :parent_id, :integer
      t.column :last_name, :string
      t.column :middle_name, :string
      t.column :first_name, :string
      t.column :last_name_transcription, :string
      t.column :middle_name_transcription, :string
      t.column :first_name_transcription, :string
      t.column :corporate_name, :string
      t.column :corporate_name_transcription, :string
      t.column :full_name, :string, :null => false
      t.column :full_name_transcription, :text
      t.column :full_name_alternative, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
      t.column :zip_code_1, :string
      t.column :zip_code_2, :string
      t.column :address_1, :text
      t.column :address_2, :text
      t.column :address_1_note, :text
      t.column :address_2_note, :text
      t.column :other_designation, :text
      t.column :place, :text
      t.column :date_of_birth, :timestamp
      t.column :date_of_death, :timestamp
      t.column :language_id, :integer, :default => 1, :null => false
      t.column :country_id, :integer, :default => 1, :null => false
      t.column :patron_type_id, :integer, :default => 1, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :note, :text
      t.column :creates_count, :integer, :default => 0, :null => false
      t.column :realizes_count, :integer, :default => 0, :null => false
      t.column :produces_count, :integer, :default => 0, :null => false
      t.column :owns_count, :integer, :default => 0, :null => false
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :access_role_id, :integer, :null => false
    end
    add_index :patrons, :parent_id
    add_index :patrons, :patron_type_id
    add_index :patrons, :language_id
    add_index :patrons, :country_id
    add_index :patrons, :access_role_id
    add_index :patrons, :full_name
  end

  def self.down
    drop_table :patrons
  end
end
