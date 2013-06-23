class AddUrlToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :url, :string
  end
end
