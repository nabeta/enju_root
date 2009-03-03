module OwnerRequired
  def self.is_indexable_by(user, parent = nil)
    true
  end

  def self.is_creatable_by(user, parent = nil)
    true
  end

  def is_readable_by(user, parent = nil)
    true if user == self.user
  end

  def is_updatable_by(user, parent = nil)
    true if user == self.user
  end

  def is_deletable_by(user, parent = nil)
    true if user == self.user
  end

end
