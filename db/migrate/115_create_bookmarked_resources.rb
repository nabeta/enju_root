class CreateBookmarkedResources < ActiveRecord::Migration
  def self.up
    create_table :bookmarked_resources do |t|
      t.text :title
      t.string :url, :null => false
      t.integer :manifestation_id, :null => false
      t.integer :bookmarks_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :bookmarked_resources, :url
    add_index :bookmarked_resources, :manifestation_id
  end

  def self.down
    drop_table :bookmarked_resources
  end
end
