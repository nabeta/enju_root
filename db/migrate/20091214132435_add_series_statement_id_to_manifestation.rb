class AddSeriesStatementIdToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :series_statement_id, :integer
    add_index :manifestations, :series_statement_id
  end

  def self.down
    remove_column :manifestations, :series_statement_id
  end
end
