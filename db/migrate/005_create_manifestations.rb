class CreateManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestations do |t|
      t.column :parent_id, :integer
      t.column :original_title, :text, :null => false
      t.column :title_alternative, :text
      t.column :title_transcription, :text
      t.column :classification_number, :string
      t.column :manifestation_identifier, :string
      t.column :date_of_publication, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
      t.column :access_address, :string
      t.column :language_id, :integer, :default => 1, :null => false
      t.column :manifestation_form_id, :integer, :default => 1, :null => false
      t.column :start_page, :integer
      t.column :end_page, :integer
      t.column :height, :decimal
      t.column :width, :decimal
      t.column :depth, :decimal
      t.column :isbn, :string
      t.column :isbn10, :string
      t.column :wrong_isbn, :string
      t.column :nbn, :string
      t.column :price, :decimal # TODO: 通貨単位
      #t.column :filename, :text
      #t.column :content_type, :string
      #t.column :size, :integer
      t.column :volume_number_list, :string
      t.column :issue_number_list, :string
      t.column :serial_number_list, :string
      t.column :edition, :integer
      t.column :note, :text
      t.column :produces_count, :integer, :default => 0, :null => false
      t.column :exemplifies_count, :integer, :default => 0, :null => false
      t.column :embodies_count, :integer, :default => 0, :null => false
      t.column :exemplifies_count, :integer, :default => 0, :null => false
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :repository_content, :boolean, :default => false, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
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
