class AddFradAttributesToPerson < ActiveRecord::Migration
  def change
    add_column :people, :date_of_bitrh, :datetime
    add_column :people, :date_of_death, :datetime
    add_column :people, :period_of_activity, :text
    add_column :people, :title, :text
    add_column :people, :gender_id, :integer
    add_column :people, :place_of_birth, :string
    add_column :people, :place_of_death, :string
    add_column :people, :country_id, :integer
    add_column :people, :place_of_residence, :string
    add_column :people, :affiliation, :string
    add_column :people, :address, :text
    add_column :people, :field_of_activity, :text
    add_column :people, :profession, :string
    add_column :people, :history, :text
    add_column :people, :other_information_elements, :text
  end
end
