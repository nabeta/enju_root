class CreateWorkRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :work_relationship_types do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
