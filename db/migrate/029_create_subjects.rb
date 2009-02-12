class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.column :parent_id, :integer
      t.column :use_term_id, :integer
      t.column :term, :string
      t.column :term_transcription, :text
      t.column :subject_type_id, :integer, :null => false
      t.column :scope_note, :text
      t.column :note, :text
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :subjects, :term
    add_index :subjects, :parent_id
    add_index :subjects, :use_term_id
    add_index :subjects, :subject_type_id
  end

  def self.down
    drop_table :subjects
  end
end
