class CreateManifestationApiResponses < ActiveRecord::Migration
  def self.up
    create_table :manifestation_api_responses do |t|
      t.column :manifestation_id, :integer, :null => false
      t.column :type, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :manifestation_api_responses, [:manifestation_id, :type], :unique => true
  end

  def self.down
    drop_table :manifestation_api_responses
  end
end
