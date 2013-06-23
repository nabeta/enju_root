class AddRelationshipTypeIdToEmbody < ActiveRecord::Migration
  def change
    add_column :embodies, :relationship_type_id, :integer
  end
end
