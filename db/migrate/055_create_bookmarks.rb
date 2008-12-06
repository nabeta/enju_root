class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks, :force => true do |t|
      t.column :user_id, :integer, :null => false
      t.column :bookmarked_resource_id, :integer, :null => false
      t.column :note, :text
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    add_index :bookmarks, :user_id
    add_index :bookmarks, :bookmarked_resource_id
  end

  def self.down
    drop_table :bookmarks
  end
end
