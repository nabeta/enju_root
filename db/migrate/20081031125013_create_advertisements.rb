class CreateAdvertisements < ActiveRecord::Migration
  def self.up
    create_table :advertisements do |t|
      t.string :title, :null => false
      t.string :url, :null => false
      t.text :body
      t.text :note
      t.datetime :started_at
      t.datetime :ended_at
      t.datetime :deleted_at
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :advertisements
  end
end
