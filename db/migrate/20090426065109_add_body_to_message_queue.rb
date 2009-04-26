class AddBodyToMessageQueue < ActiveRecord::Migration
  def self.up
    add_column :message_queues, :body, :text
  end

  def self.down
    remove_column :message_queues, :body
  end
end
