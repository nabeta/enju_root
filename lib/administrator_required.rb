module AdministratorRequired
  def self.included(base)
    base.extend AclClassMethods
    base.instance_eval do
      include InstanceMethods
    end
  end

  module AclClassMethods
    def is_indexable_by(user, parent = nil)
      #true if user.has_role?('Administrator')
      true if user.has_role?('Librarian')
    rescue
      false
    end

    def is_creatable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      false
    end
  end

  module InstanceMethods
    #include RoleRequired

    def is_readable_by(user, parent = nil)
      #true if user.has_role?('Administrator')
      return true if user.has_role?('Librarian')
      return true if self.role_accepted?(user)
    rescue
      false
    end

    def is_updatable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      false
    end

    def is_deletable_by(user, parent = nil)
      true if user.has_role?('Administrator')
    rescue
      false
    end
  end
end
