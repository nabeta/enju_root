class RenameMessageQueueToMessageRequest < ActiveRecord::Migration
  def self.up
    rename_table :message_queues, :message_requests
    rename_column :messages, :message_queue_id, :message_request_id
  end

  def self.down
    rename_table :message_requests, :message_queues
    rename_column :messages, :message_request_id, :message_queue_id
  end
end
