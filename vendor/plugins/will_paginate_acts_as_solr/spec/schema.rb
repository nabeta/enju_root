ActiveRecord::Schema.define(:version => 1) do
  create_table :some_models, :force => true do |t|
    t.string :name
    t.text :data
    t.string :something_else, :default => nil
    t.boolean :active, :default => false, :null => false

    t.timestamps
  end
end