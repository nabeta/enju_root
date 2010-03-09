module RoleRequired
  def role_accepted?(user)
    if self.respond_to?(:required_role_id)
      #role = user.try(:highest_role) || Rails.cache.fetch("Role_1"){Role.find(1)}
      if user.try(:highest_role)
        role_id = user.highest_role.id
      else
        role_id = 1
      end
      true if self.required_role_id <= role_id
    end
  end
end
