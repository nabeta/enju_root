class CreateSubjectBroaderTerms < ActiveRecord::Migration
  def self.up
    create_table :subject_broader_terms do |t|
      t.integer :narrower_term_id, :broader_term_id, :null => false
      t.timestamps
    end
    add_index :subject_broader_terms, :narrower_term_id
    add_index :subject_broader_terms, :broader_term_id
  end

  def self.down
    drop_table :subject_broader_terms
  end
end
