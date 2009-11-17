class Exemplify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :manifestation #, :counter_cache => true, :validate => true
  belongs_to :item #, :validate => true

  validates_associated :manifestation, :item
  validates_presence_of :manifestation_id, :item_id
  validates_uniqueness_of :item_id

  acts_as_list :scope => :manifestation_id

  @@per_page = 10
  cattr_accessor :per_page

  def after_save
    manifestation.index!
    item.index!
  end

  def after_destroy
    after_save
  end

  def after_create
    create_lending_policy
  end

  def create_lending_policy
    UserGroupHasCheckoutType.available_for_carrier_type(manifestation.carrier_type).each do |rule|
      LendingPolicy.create(:item_id => item.id, :user_group_id => rule.user_group_id, :fixed_due_date => rule.fixed_due_date, :loan_period => rule.checkout_period, :renewal => rule.checkout_renewal_limit)
    end
  end

end
