class AddRelationshipTypeToReify < ActiveRecord::Migration
  def self.up
    add_column :reifies, :relationship_type_id, :integer
  end

  def self.down
    remove_column :reifies, :relationship_type
  end
end
