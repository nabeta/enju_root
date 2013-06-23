class AddDefinitionToRelationshipType < ActiveRecord::Migration
  def change
    add_column :work_relationship_types, :definition, :text
    add_column :expression_relationship_types, :definition, :text
    add_column :work_relationship_types, :url, :string
    add_column :expression_relationship_types, :url, :string
  end
end
