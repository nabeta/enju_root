class AddRelationshipTypeToWork < ActiveRecord::Migration
  def self.up
    add_column :patron_has_patrons, :patron_relationship_type_id, :integer, :null => false
    add_column :work_has_works, :work_relationship_type_id, :integer, :null => false
    add_column :expression_has_expressions, :expression_relationship_type_id, :integer, :null => false
    add_column :manifestation_has_manifestations, :manifestation_relationship_type_id, :integer, :null => false
    add_column :item_has_items, :item_relationship_type_id, :integer, :null => false
  end

  def self.down
    remove_column :patron_has_patrons, :patron_relationship_type_id
    remove_column :work_has_works, :work_relationship_type_id
    remove_column :expression_has_expressions, :expression_relationship_type_id
    remove_column :manifestation_has_manifestations, :manifestation_relationship_type_id
    remove_column :item_has_items, :item_relationship_type_id
  end
end
