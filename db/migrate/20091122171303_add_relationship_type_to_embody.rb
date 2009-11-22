class AddRelationshipTypeToEmbody < ActiveRecord::Migration
  def self.up
    add_column :embodies, :relationship_type_id, :integer
  end

  def self.down
    remove_column :embodies, :relationship_type
  end
end
