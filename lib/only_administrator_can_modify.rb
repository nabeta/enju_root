module OnlyAdministratorCanModify
  def self.included(base)
    base.extend AclClassMethods
    base.__send__ :include, InstanceMethods
  end

  module AclClassMethods
    def is_indexable_by(user, parent = nil)
      true
    end

    def is_creatable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      nil
    end
  end

  module InstanceMethods
    def is_readable_by(user, parent = nil)
      true
    end

    def is_updatable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      nil
    end

    def is_deletable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      nil
    end
  end
end
