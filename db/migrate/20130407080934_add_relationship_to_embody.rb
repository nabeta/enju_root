class AddRelationshipToEmbody < ActiveRecord::Migration
  def change
    add_column :embodies, :relationship, :string
  end
end
