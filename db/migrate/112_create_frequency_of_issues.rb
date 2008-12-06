class CreateFrequencyOfIssues < ActiveRecord::Migration
  def self.up
    create_table :frequency_of_issues do |t|
      t.string :name
      t.string :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :frequency_of_issues
  end
end
