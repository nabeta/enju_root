module RoleRequired
  def role_accepted?(user)
    if self.respond_to?(:required_role_id)
      role = user.try(:highest_role) || Rails.cache.fetch("Role_1"){Role.find(1)}
      true if self.required_role_id <= role.id
    end
  end
end
