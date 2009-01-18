class CreateManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestations do |t|
      t.integer :parent_id
      t.text :original_title, :null => false
      t.text :title_alternative
      t.text :title_transcription
      t.string :classification_number
      t.string :manifestation_identifier
      t.datetime :date_of_publication
      t.timestamps
      t.datetime :deleted_at
      t.string :access_address
      t.integer :language_id, :default => 1, :null => false
      t.integer :manifestation_form_id, :default => 1, :null => false
      t.integer :start_page
      t.integer :end_page
      t.decimal :height
      t.decimal :width
      t.decimal :depth
      t.string :isbn
      t.string :isbn10
      t.string :wrong_isbn
      t.strint :nbn
      t.decimal :price # TODO: 通貨単位
      #t.text :filename
      #t.string :content_type
      #t.integer :size
      t.string :volume_number_list
      t.string :issue_number_list
      t.string :serial_number_list
      t.integer :edition
      t.text :note
      t.integer :produces_count, :default => 0, :null => false
      t.integer :exemplifies_count, :default => 0, :null => false
      t.integer :embodies_count, :default => 0, :null => false
      t.integer :exemplifies_count, :default => 0, :null => false
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.boolean :repository_content, :default => false, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.integer :access_role_id, :default => 1, :null => false
      t.string :state
    end
    add_index :manifestations, :parent_id
    add_index :manifestations, :manifestation_form_id
    add_index :manifestations, :access_role_id
    add_index :manifestations, :isbn
    add_index :manifestations, :nbn
    add_index :manifestations, :access_address
  end

  def self.down
    drop_table :manifestations
  end
end
