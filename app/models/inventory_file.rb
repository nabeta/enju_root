class InventoryFile < ActiveRecord::Base
  has_many :inventories, :dependent => :destroy
  has_many :items, :through => :inventories
  belongs_to :user
  has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_as_attachment

  cattr_reader :per_page
  @@per_page = 10

  def import
    self.reload
    reader = self.db_file.data
    reader.each do |row|
      begin
        item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ?', row.to_s.strip])
        self.items << item if item
      rescue
        nil
      end
    end
  end

end
