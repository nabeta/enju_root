class CreateSearchHistories < ActiveRecord::Migration
  def self.up
    create_table :search_histories do |t|
      t.column :user_id, :integer
      t.column :operation, :string, :default => 'searchRetrieve'
      t.column :version, :float, :default => 1.2
      t.column :query, :string
      t.column :start_record, :integer
      t.column :maximum_records, :integer
      t.column :record_packing, :string
      t.column :record_schema, :string
      t.column :result_set_ttl, :integer
      t.column :stylesheet, :string
      t.column :extra_request_data, :string
      t.column :number_of_records, :integer, :default => 0
      t.column :result_set_id, :string
      t.column :result_set_idle_time, :integer
      t.column :records, :text
      t.column :next_record_position, :integer
      t.column :diagnostics, :text
      t.column :extra_response_data, :text
      t.column :echoed_search_retrieve_request, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :search_histories, :user_id
  end

  def self.down
    drop_table :search_histories
  end
end
