class AddFormOfWorkToWork < ActiveRecord::Migration
  def change
    add_column :works, :form_of_work, :string
    add_column :works, :date_of_work, :date
  end
end
