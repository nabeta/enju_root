class CreateExpressionToManifestationRelTypes < ActiveRecord::Migration
  def self.up
    create_table :expression_to_manifestation_rel_types do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :expression_to_manifestation_rel_types
  end
end
