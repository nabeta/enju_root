class AddStateToMessageQueue < ActiveRecord::Migration
  def self.up
    add_column :message_queues, :state, :string
    add_index :message_queues, :state
  end

  def self.down
    remove_column :message_queues, :state
  end
end
