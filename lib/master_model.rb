module MasterModel
  def self.included(base)
  #  base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      acts_as_list
      validates_uniqueness_of :name, :case_sensitive => false
      validates_presence_of :name, :display_name
      before_validation_on_create :set_display_name
    end
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
