class CreateCarrierTypes < ActiveRecord::Migration
  def change
    create_table :carrier_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
