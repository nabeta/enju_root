class CreateExpressions < ActiveRecord::Migration
  def self.up
    create_table :expressions do |t|
      t.text :original_title, :null => false
      t.text :title_transcription
      t.text :title_alternative
      t.text :summarization
      t.text :context
      t.integer :language_id, :default => 1, :null => false
      t.integer :content_type_id, :default => 1, :null => false
      #t.string :sequencing_pattern
      #t.boolean :serial, :default => false, :null => false
      #t.string :issn
      t.text :note
      t.integer :realizes_count, :default => 0, :null => false
      t.integer :embodies_count, :default => 0, :null => false
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.integer :required_role_id, :default => 1, :null => false
      t.string :feed_url
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.integer :content_type_id, :default => 1, :null => false
      t.datetime :date_of_expression
    end
    add_index :expressions, :language_id
    add_index :expressions, :content_type_id
    add_index :expressions, :required_role_id
    #add_index :expressions, :issn
  end

  def self.down
    drop_table :expressions
  end
end
