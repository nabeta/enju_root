class RenameAnswerRssTokenToAnswerFeedToken < ActiveRecord::Migration
  def self.up
    rename_column :users, :answer_rss_token, :answer_feed_token
    add_index :users, :answer_feed_token
  end

  def self.down
    rename_column :users, :answer_feed_token, :answer_rss_token
    remove_index :users, :answer_feed_token
  end
end
