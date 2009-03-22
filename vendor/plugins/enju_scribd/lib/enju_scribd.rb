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
    attr_accessor :post_to_scribd, :post_to_twitter
    def scribdable?
      return false if RAILS_ENV != 'production'
      if post_to_scribd
        ScribdFu::CONTENT_TYPES.include?(content_type)
      else
        false
      end
    end
  end
end
