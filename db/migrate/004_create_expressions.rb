class CreateExpressions < ActiveRecord::Migration
  def self.up
    create_table :expressions do |t|
      t.column :parent_id, :integer
      t.column :original_title, :text, :null => false
      t.column :title_transcription, :text
      t.column :title_alternative, :text
      t.column :summarization, :text
      t.column :context, :text
      t.column :language_id, :integer, :default => 1, :null => false
      t.column :expression_form_id, :integer, :default => 1, :null => false
      #t.column :sequencing_pattern, :string
      t.column :frequency_of_issue_id, :integer, :default => 1, :null => false
      #t.column :serial, :boolean, :default => false, :null => false
      t.column :issn, :string
      t.column :note, :text
      t.column :realizes_count, :integer, :default => 0, :null => false
      t.column :embodies_count, :integer, :default => 0, :null => false
      t.column :resource_has_subjects_count, :integer, :default => 0, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
      t.integer :access_role_id, :default => 1, :null => false
    end
    add_index :expressions, :parent_id
    add_index :expressions, :language_id
    add_index :expressions, :expression_form_id
    add_index :expressions, :frequency_of_issue_id
    add_index :expressions, :access_role_id
    add_index :expressions, :issn
  end

  def self.down
    drop_table :expressions
  end
end
