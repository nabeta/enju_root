class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.column :parent_id, :integer
      t.column :original_title, :text, :null => false
      t.column :title_transcription, :text
      t.column :title_alternative, :text
      t.column :context, :text
      t.column :work_form_id, :integer, :default => 1, :null => false
      t.column :note, :text
      t.column :creates_count, :integer, :default => 0, :null => false
      t.column :reifies_count, :integer, :default => 0, :null => false
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
      t.integer :access_role_id, :default => 1, :null => false
    end
    add_index :works, :work_form_id
    add_index :works, :parent_id
    add_index :works, :access_role_id
  end

  def self.down
    drop_table :works
  end
end
