require 'test_helper'

class ManifestationsControllerTest < ActionController::TestCase
  fixtures :manifestations, :manifestation_forms, :resource_has_subjects, :languages, :concepts, :places, :subjects, :subject_types
  fixtures :works, :work_forms, :realizes
  fixtures :expressions, :expression_forms, :frequency_of_issues
  fixtures :items, :libraries, :shelves, :languages, :exemplifies
  fixtures :embodies
  fixtures :patrons, :user_groups, :users, :bookmarks, :bookmarked_resources, :roles
  fixtures :people, :corporate_bodies, :families

  def test_guest_should_get_index
    old_search_history_count = SearchHistory.count
    get :index
    assert_response :success
    assert assigns(:manifestations)
    assert_equal old_search_history_count, SearchHistory.count
  end

  def test_guest_should_get_index_xml
    old_search_history_count = SearchHistory.count
    get :index, :format => 'xml'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal old_search_history_count, SearchHistory.count
  end

  def test_guest_should_get_index_csv
    old_search_history_count = SearchHistory.count
    get :index, :format => 'csv'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal old_search_history_count, SearchHistory.count
  end

  def test_guest_should_create_search_history
    old_search_history_count = SearchHistory.count
    get :index, :query => 'test'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal old_search_history_count + 1, SearchHistory.count
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_expression
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:expression)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_subject
    get :index, :subject_id => 1
    assert_response :success
    assert assigns(:subject)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_query
    get :index, :query => '2005'
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_all_facet
    get :index, :query => '2005', :view => 'all_facet'
    assert_response :success
    assert assigns(:facet_results)
  end

  def test_guest_should_get_index_manifestation_form_facet
    get :index, :query => '2005', :view => 'manifestation_form_facet'
    assert_response :success
    assert assigns(:facet_results)
  end

  def test_guest_should_get_index_language_facet
    get :index, :query => '2005', :view => 'language_facet'
    assert_response :success
    assert assigns(:facet_results)
  end

  def test_guest_should_get_index_library_facet
    get :index, :query => '2005', :view => 'library_facet'
    assert_response :success
    assert assigns(:facet_results)
  end

  def test_guest_should_get_index_subject_facet
    get :index, :query => '2005', :view => 'subject_facet'
    assert_response :success
    assert assigns(:facet_results)
  end

  def test_guest_should_get_index_tag_cloud
    get :index, :query => '2005', :view => 'tag_cloud'
    assert_response :success
    assert assigns(:tags)
  end

  def test_user_should_save_search_history
    old_search_history_count = SearchHistory.count
    login_as :admin
    get :index, :query => '2005'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal old_search_history_count + 1, SearchHistory.count
  end

  #def test_user_should_save_search_history_when_allowed
  #  old_search_history_count = SearchHistory.count
  #  login_as :admin
  #  get :index, :query => '2005'
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count + 1, SearchHistory.count
  #end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  #def test_user_should_not_save_search_history_when_not_allowed
  #  old_search_history_count = SearchHistory.count
  #  login_as :user1
  #  get :index
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count, SearchHistory.count
  #end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_new_without_expression_id
    login_as :librarian1
    get :new
    assert_response :redirect
    assert_redirected_to expressions_url
  end
  
  def test_librarian_should_get_new_with_expression_id
    login_as :librarian1
    get :new, :expression_id => 1
    assert_response :success
  end
  
  def test_admin_should_get_new_without_expression_id
    login_as :admin
    get :new
    assert_response :redirect
    assert_redirected_to expressions_url
    assert_equal 'Please specify expression id.', flash[:notice]
  end
  
  def test_admin_should_get_new_with_expression_id
    login_as :admin
    get :new, :expression_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_manifestation
    old_count = Manifestation.count
    post :create, :manifestation => { :original_title => 'test', :manifestation_form_id => 1 }
    assert_equal old_count, Manifestation.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_manifestation
    login_as :user1
    old_count = Manifestation.count
    post :create, :manifestation => { :original_title => 'test', :manifestation_form_id => 1 }
    assert_equal old_count, Manifestation.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_manifestation_without_expression
    login_as :librarian1
    old_count = Manifestation.count
    post :create, :manifestation => { :original_title => 'test', :manifestation_form_id => 1, :language_id => 1 }
    assert_equal old_count, Manifestation.count
    
    assert_response :redirect
    assert_redirected_to expressions_url
    assert_equal 'Please specify expression id.', flash[:notice]
  end

  def test_librarian_should_not_create_manifestation_without_title
    login_as :librarian1
    old_count = Manifestation.count
    post :create, :manifestation => { :manifestation_form_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count, Manifestation.count
    
    assert_response :success
  end

  def test_librarian_should_create_manifestation_with_expression
    login_as :librarian1
    old_count = Manifestation.count
    post :create, :manifestation => { :original_title => 'test', :manifestation_form_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count+1, Manifestation.count
    
    assert assigns(:expression)
    assert assigns(:manifestation)
    assert assigns(:manifestation).embodies
    assert_redirected_to manifestation_patrons_url(assigns(:manifestation))
  end

  def test_librarian_should_import_manifestation_with_isbn
    login_as :librarian1
    old_count = Manifestation.count
    post :create, :manifestation => { :isbn => '4820403303' }, :mode => 'import_isbn'
    assert_equal old_count+1, Manifestation.count
    
    assert assigns(:manifestation)
    assert assigns(:manifestation).embodies
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_librarian_should_not_import_manifestation_with_wrong_isbn
    login_as :librarian1
    old_count = Manifestation.count
    post :create, :manifestation => { :isbn => '4820403303x' }, :mode => 'import_isbn'
    assert_equal old_count, Manifestation.count
    
    assert_nil assigns(:manifestation)
    assert_redirected_to new_manifestation_url(:mode => 'import_isbn')
  end

  def test_admin_should_create_manifestation_with_expression
    login_as :admin
    old_count = Manifestation.count
    post :create, :manifestation => { :original_title => 'test', :manifestation_form_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count+1, Manifestation.count
    
    assert assigns(:expression)
    assert assigns(:manifestation)
    assert assigns(:manifestation).embodies
    assert_redirected_to manifestation_patrons_url(assigns(:manifestation))
  end

  def test_guest_should_show_manifestation
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_holding
    get :show, :id => 1, :mode => 'holding'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_edit
    get :show, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_list
    get :show, :id => 1, :mode => 'tag_list'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_authors
    get :show, :id => 1, :mode => 'show_authors'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_all_authors
    get :show, :id => 1, :mode => 'show_all_authors'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_isbn
    get :show, :isbn => "4798002062"
    assert_response :redirect
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_guest_should_not_show_manifestation_with_invalid_isbn
    get :show, :isbn => "4798002062a"
    assert_response :missing
  end

  def test_user_should_show_manifestation
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_manifestation
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_manifestation_with_expression_not_embodied
    login_as :librarian1
    get :show, :id => 1, :expression_id => 3
    assert_response :success
  end

  def test_librarian_should_show_manifestation_with_patron_not_produced
    login_as :librarian1
    get :show, :id => 1, :patron_id => 2
    assert_response :success
  end

  def test_admin_should_show_manifestation
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_edit_with_tag_edit
    login_as :user1
    get :edit, :id => 1, :mode => 'tag_edit'
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_librarian_should_get_edit_upload
    login_as :librarian1
    get :edit, :id => 1, :upload => true
    assert_response :success
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_manifestation
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_manifestation
    login_as :user1
    put :update, :id => 1, :manifestation => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_manifestation_without_title
    login_as :librarian1
    put :update, :id => 1, :manifestation => { :original_title => nil }
    assert_response :success
  end
  
  def test_librarian_should_update_manifestation
    login_as :librarian1
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end
  
  def test_admin_should_update_manifestation
    login_as :admin
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end
  
  def test_guest_should_not_destroy_manifestation
    old_count = Manifestation.count
    delete :destroy, :id => 1
    assert_equal old_count, Manifestation.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_manifestation
    login_as :user1
    old_count = Manifestation.count
    delete :destroy, :id => 1
    assert_equal old_count, Manifestation.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_manifestation
    login_as :librarian1
    old_count = Manifestation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Manifestation.count
    
    assert_redirected_to manifestations_url
  end

  def test_admin_should_destroy_manifestation
    login_as :admin
    old_count = Manifestation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Manifestation.count
    
    assert_redirected_to manifestations_url
  end
end
