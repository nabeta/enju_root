class CreateManifestationApiResponses < ActiveRecord::Migration
  def self.up
    create_table :manifestation_api_responses do |t|
      t.integer :manifestation_id, :null => false
      t.string :type
      t.text :body
      t.timestamps
    end
    add_index :manifestation_api_responses, [:manifestation_id, :type], :unique => true
  end

  def self.down
    drop_table :manifestation_api_responses
  end
end
