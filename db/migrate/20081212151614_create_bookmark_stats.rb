class CreateBookmarkStats < ActiveRecord::Migration
  def self.up
    create_table :bookmark_stats do |t|
      t.datetime :from_date
      t.datetime :to_date
      t.text :note
      t.string :state, :default => 'pending', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmark_stats
  end
end
