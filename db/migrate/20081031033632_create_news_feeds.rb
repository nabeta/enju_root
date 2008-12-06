class CreateNewsFeeds < ActiveRecord::Migration
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

  def self.down
    drop_table :news_feeds
  end
end
