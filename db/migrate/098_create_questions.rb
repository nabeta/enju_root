class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :user_id
      t.text :body
      t.boolean :private_question, :default => true, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.string :state, :default => 'pending'
    end
    add_index :questions, :user_id
  end

  def self.down
    drop_table :questions
  end
end
