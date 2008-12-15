ActionController::Routing::Routes.draw do |map|
  map.resources :user_stat_has_checkouts

  map.resources :user_stats

  map.resources :bookmark_stat_has_manifestations

  map.resources :bookmark_stats

  map.resources :checkout_stats

  map.resources :checkout_stat_has_manifestations

  map.resources :item_relationship_types

  map.resources :manifestation_relationship_types

  map.resources :expression_relationship_types

  map.resources :work_relationship_types

  map.resources :item_has_items

  map.resources :manifestation_has_manifestations

  map.resources :expression_has_expressions

  map.resources :work_has_works

  map.resources :inventories

  map.resources :inventory_files do |inventory_file|
    inventory_file.resources :inventories
    inventory_file.resources :items
  end

  map.resources :barcodes

  map.resources :advertisements

  map.resources :advertises

  map.resources :news_feeds

  map.resources :item_has_checkout_types

  map.resources :manifestation_form_has_checkout_types

  map.resources :user_group_has_checkout_types

  map.resources :checkout_types do |checkout_type|
    checkout_type.resources :user_groups
    checkout_type.resources :user_group_has_checkout_types
    checkout_type.resources :manifestation_forms
    checkout_type.resources :manifestation_form_has_checkout_types
  end

  map.resources :search_engines


  map.resources :order_lists do |order_list|
    order_list.resources :orders
    order_list.resources :purchase_requests
  end

  map.resources :subscribes

  map.resources :subscriptions do |subscription|
    subscription.resources :subscribes
    subscription.resources :expressions
  end

  map.resources :subscriptions

  map.resources :imported_objects
  map.resources :patron_types

  map.resources :imported_files
  map.resources :imported_patron_files
  map.resources :imported_event_files
  map.resources :imported_resource_files
  map.resources :picture_files

  map.resources :exemplifies

  map.resources :message_queues

  map.resources :message_templates

  map.resources :subject_types

  map.resources :classification_types

  map.resources :classifications do |classification|
    classification.resources :subjects
    classification.resources :subject_has_classifications
  end

  map.resources :subjects do |subject|
    subject.resources :manifestations
    subject.resources :resource_has_subjects
    subject.resources :classifications
    subject.resources :subject_has_classifications
  end

  map.resources :patron_merge_lists do |patron_merge_list|
    patron_merge_list.resources :patrons
    patron_merge_list.resources :patron_merges
  end

  map.resources :work_merge_lists do |work_merge_list|
    work_merge_list.resources :works
    work_merge_list.resources :work_merges
  end

  map.resources :expression_merge_lists do |expression_merge_list|
    expression_merge_list.resources :expressions
    expression_merge_list.resources :expression_merges
  end

  map.resources :tags do |tag|
    tag.resources :subjects
  end
  map.resources :circulation_statuses

  map.resources :request_types

  map.resources :request_status_types

  map.resources :use_restrictions

  map.resources :donates

  map.resources :bookstores do |bookstore|
    bookstore.resources :order_lists
  end

  map.resources :checked_items

  map.resources :patrons do |patron|
    patron.resources :works
    patron.resources :expressions
    patron.resources :manifestations
    patron.resources :items
    patron.resources :creates
    patron.resources :realizes
    patron.resources :produces
    patron.resources :owns
    patron.resources :patron_owns_libraries
    patron.resources :patron_merges
    patron.resources :patron_merge_lists
    patron.resources :resource_has_subjects
    patron.resources :attachment_files
    patron.resources :donates
    patron.resources :advertises
    patron.resources :advertisements
  end
  map.resources :users do |user|
    user.resources :roles
    user.resources :bookmarks
    user.resources :bookmarked_resources
    user.resources :reserves
    user.resources :search_histories
    user.resources :checkouts
    user.resources :messages,   
                    :collection => {:destroy_selected => :post,   
                                    :inbox            => :get,   
                                    :outbox           => :get,   
                                    :trashbin         => :get},   
                    :member => {:reply => :get}
    user.resources :questions do |question|
      question.resources :answers
    end
    user.resources :answers
    user.resources :purchase_requests do |purchase_request|
      purchase_request.resources :orders
    end
    user.resources :baskets do |basket|
      basket.resources :checked_items
      basket.resources :checkins
    end
    user.resources :tags
    user.resources :imported_event_files
    user.resources :imported_patron_files
    user.resources :imported_resource_files
    user.resources :order_lists
    user.resources :subscriptions
  end
  map.resources :sessions
  map.resources :works do |work|
    work.resources :expressions
    work.resources :patrons
    work.resources :creates
    work.resources :work_merges
    work.resources :work_merge_lists
    work.resources :resource_has_subjects
  end
  map.resources :expressions do |expression|
    expression.resource :realize
    expression.resource :work
    expression.resources :patrons
    expression.resources :reifies
    expression.resources :realizes
    expression.resources :embodies
    expression.resources :manifestations
    expression.resources :expression_merges
    expression.resources :expression_merge_lists
    expression.resources :resource_has_subjects
    expression.resource :subscribe
  end
  map.resources :manifestations do |manifestation|
    manifestation.resources :attachment_files
    manifestation.resources :picture_files
    manifestation.resources :patrons
    manifestation.resources :produces
    manifestation.resources :embodies
    manifestation.resources :exemplifies
    manifestation.resources :items
    manifestation.resources :expressions
    manifestation.resources :subjects
    manifestation.resources :resource_has_subjects
  end
  map.resources :items do |item|
    item.resources :owns
    item.resources :patrons
    item.resource :exemplify
    item.resource :manifestation
    item.resources :item_has_use_restrictions
    item.resources :inter_library_loans
    item.resources :resource_has_subjects
    item.resources :donates
    item.resource :checkout_type
    item.resource :inventory_files
  end
  map.resources :libraries do |library|
    library.resources :shelves do |shelf|
      shelf.resources :picture_files
      shelf.resources :items
    end
    library.resources :events do |event|
      event.resources :picture_files
    end
  end
  map.resources :user_groups do |user_group|
    user_group.resources :user_group_has_checkout_types
    user_group.resources :checkout_types
  end
  map.resources :work_forms
  map.resources :calendar_files
  map.resources :bookmarked_resources
  map.resources :event_categories
  map.resources :events do |event|
    event.resources :attachment_files
    event.resources :picture_files
  end
  map.resources :library_groups do |library_group|
    library_group.resources :libraries
  end
  map.resources :purchase_requests do |purchase_request|
    purchase_request.resource :order
    purchase_request.resource :order_list
  end
  map.resources :orders do |order|
    order.resources :order_lists
    order.resources :purchase_requests
  end
  map.resources :manifestation_forms do |manifestation_form|
    manifestation_form.resources :manifestation_form_has_checkout_types
    manifestation_form.resources :checkout_types
  end
  map.resources :shelves do |shelf|
    shelf.resources :items
  end
  map.resources :frequency_of_issues
  map.resources :embodies
  map.resources :languages
  map.resources :countries
  map.resources :attachment_files
  map.resources :expression_forms
  map.resources :answers
  map.resources :questions
  map.resources :checkouts
  map.resources :reserves
  map.resources :search_histories
  map.resources :bookmarks
  map.resources :roles
  map.resources :library_groups
  map.resources :user_groups
  map.resources :subjects
  map.resources :checkins
  map.resources :resource_has_subjects
  map.resources :reifies
  map.resources :creates
  map.resources :realizes
  map.resources :produces
  map.resources :owns
  map.resources :baskets
  map.resources :item_has_use_restrictions
  map.resources :patron_merges
  map.resources :patron_merge_lists
  map.resources :work_merges
  map.resources :work_merge_lists
  map.resources :expression_merges
  map.resources :expression_merge_lists
  map.resources :subject_has_classifications
  map.resources :messages
  map.resources :inter_library_loans
  map.resources :orders

  #map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.calendar '/calendar/:date', :controller => 'events', :action => 'index'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.reset_password '/reset_password', :controller => 'users', :action => 'reset_password'
  map.isbn '/isbn/:isbn', :controller => 'manifestations', :action => 'show'
  map.term '/term/:term', :controller => 'subjects', :action => 'show'
  map.icalendar '/icalendar/:icalendar_token.:format', :controller => 'checkouts', :action => 'index', :format => :ics

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  
  map.connect '', :controller => "page", :action => 'index'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
