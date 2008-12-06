class Barcode < ActiveRecord::Base
  belongs_to :barcodable, :polymorphic => true

  validates_presence_of :code_word
  validates_uniqueness_of :barcodable_id, :scope => :barcodable_type
  validates_uniqueness_of :code_word, :scope => :barcode_type

  def before_create
    self.data = Barby::Code128B.new(self.code_word).to_png(:width => 150, :height => 70)
  end
end
