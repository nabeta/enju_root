module MasterModel
  def self.included(base)
  #  base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def set_display_name
      self.display_name = self.name if self.display_name.blank?
    end

    def check_deletable
      if respond_to?(:deletable?)
        if deletable?
          raise NotDeletableError
        end
      end
    end
  end

  class NotDeletableError < StandardError; end
end
