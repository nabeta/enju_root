class CreateManifestationRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :manifestation_relationship_types do |t|
      t.string :name
      t.integer :position
      t.string :definition
      t.string :url

      t.timestamps
    end
  end
end
