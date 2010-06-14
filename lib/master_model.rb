module MasterModel
  def self.included(base)
  #  base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def set_display_name
      self.display_name = self.name if self.display_name.blank?
    end
  end
end
