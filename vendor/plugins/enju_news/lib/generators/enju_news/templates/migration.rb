class CreateEnjuNewsMigration < ActiveRecord::Migration
  def self.up
    create_table :news_feeds do |t|
      t.integer :library_group_id, :default => 1, :null => false
      t.string :title
      t.string :url
      t.text :body
      t.integer :position

      t.timestamps
    end
    #add_index :news_feeds, :library_group_id
  end

  def self.up
    create_table :news_posts do |t|
      t.text :title
      t.text :body
      t.integer :user_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer :required_role_id, :default => 1, :null => false
      t.text :note
      t.integer :position
      t.boolean :draft, :default => false, :null => false

      t.timestamps
    end
    add_index :news_posts, :user_id
  end

  def self.down
    drop_table :news_feeds
    drop_table :news_posts
  end
end
