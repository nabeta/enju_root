class AddSeriesStatementIdToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :series_statement_id, :integer
  end

  def self.down
    remove_column :works, :series_statement_id
  end
end
