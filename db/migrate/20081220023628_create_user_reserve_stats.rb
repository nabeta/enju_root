class CreateUserReserveStats < ActiveRecord::Migration
  def self.up
    create_table :user_reserve_stats do |t|
      t.datetime :from_date
      t.datetime :to_date
      t.text :note
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :user_reserve_stats
  end
end
