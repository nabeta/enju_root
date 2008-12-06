class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :null => false
      t.column :name_transcription, :string
      t.column :taggings_count, :integer, :default => 0, :null => false
      t.column :synonym, :text
      t.timestamps
    end
    
    create_table :taggings do |t|
      t.column :user_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
      t.column :taggable_id, :integer, :null => false
      
      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string, :null => false
      
      t.timestamps
    end
    
    add_index :tags, :name
    add_index :taggings, :user_id
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
