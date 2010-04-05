module ResourcesHelper
  def i18n_state(state)
    case state
    when 'not_approved'
      t('resource.not_approved')
    when 'approved'
      t('resource.approved')
    when 'published'
      t('resource.published')
    end
  end
end
