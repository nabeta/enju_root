class CorporateBody < ActiveRecord::Base
  def check_access_role(user)
    true
  end
end
