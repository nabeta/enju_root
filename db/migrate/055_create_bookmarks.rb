class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks, :force => true do |t|
      t.integer :user_id, :null => false
      t.integer :manifestation_id, :null => false
      t.text :note
      t.timestamps
    end

    add_index :bookmarks, :user_id
    add_index :bookmarks, :manifestation_id
  end

  def self.down
    drop_table :bookmarks
  end
end
