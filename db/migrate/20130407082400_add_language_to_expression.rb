class AddLanguageToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :language, :string
  end
end
