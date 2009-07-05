module EnjuScribd
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_scribd
      include EnjuScribd::InstanceMethods
    end
  end

  module InstanceMethods
  end
end
