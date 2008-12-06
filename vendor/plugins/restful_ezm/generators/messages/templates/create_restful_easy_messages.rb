class CreateRestfulEasyMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.boolean  :receiver_deleted, :receiver_purged, :sender_deleted, :sender_purged
      t.datetime :read_at
      t.integer  :receiver_id, :sender_id
      t.string   :subject, :null => false
      t.text     :body
      t.timestamps 
    end
    
    add_index :messages, :sender_id
    add_index :messages, :receiver_id
  end

  def self.down
    drop_table :messages
  end
end
