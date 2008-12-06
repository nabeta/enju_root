class CreateManifestationForms < ActiveRecord::Migration
  def self.up
    create_table :manifestation_forms do |t|
      t.column :name, :string, :null => false
      t.column :display_name, :string
      t.column :note, :text
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :manifestation_forms
  end
end
