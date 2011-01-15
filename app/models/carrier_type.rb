class CarrierType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :resources

  def mods_type
    case name
    when 'print'
      'text'
    else
      # TODO: その他のタイプ
      'software, multimedia'
    end
  end
end
