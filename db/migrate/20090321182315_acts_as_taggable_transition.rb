class ActsAsTaggableTransition < ActiveRecord::Migration
  def self.up
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string
    add_column :taggings, :context, :string
    execute "UPDATE taggings SET tagger_type = 'User'"
    execute "UPDATE taggings SET tagger_id = user_id"
    execute "UPDATE taggings SET context = 'tags'"
    remove_index :taggings, :user_id
    remove_index :taggings, [:taggable_id, :taggable_type]
    remove_column :taggings, :user_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    add_column :taggings, :user_id, :integer
    execute "UPDATE taggings SET user_id = tagger_id"
    remove_column :taggings, :tagger_id
    remove_column :taggings, :tagger_type
    remove_column :taggings, :context
    add_index :taggings, :user_id
    add_index :taggings, [:taggable_id, :taggable_type]
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
