class AddRelationshipTypeIdToReify < ActiveRecord::Migration
  def change
    add_column :reifies, :relationship_type_id, :integer
  end
end
