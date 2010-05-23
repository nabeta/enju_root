WillPaginate::ViewHelpers.pagination_options[:previous_label] = "&#171; " + I18n.t('page.previous')
WillPaginate::ViewHelpers.pagination_options[:next_label] = "&#187; " + I18n.t('page.next')
WillPaginate::ViewHelpers.pagination_options[:class] = "digg_pagination"

WillPaginate::ViewHelpers.module_eval do
  safe_helper :will_paginate, :paginated_section, :page_entries_info
end
