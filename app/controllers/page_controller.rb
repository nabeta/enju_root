class PageController < ApplicationController
  before_filter :store_location
  before_filter :require_user, :except => [:index, :advanced_search, :about, :message, :add_on]
  before_filter :get_libraries, :only => [:advanced_search]
  before_filter :get_user # 上書き注意
  require_role 'Librarian', :except => [:index, :advanced_search, :about, :message, :add_on]

  def index
    if logged_in?
      redirect_to user_url(current_user.login)
    else
      redirect_to :controller => 'public_page', :action => 'index'
    end
  end

  def patron
    @title = t('page.patron_management')
  end
  
  def advanced_search
    @title = t('page.advanced_search')
  end

  def message
    if logged_in?
      redirect_to inbox_user_messages_url(current_user.login)
    else
      redirect_to new_user_session_url
    end
  end

  def circulation
    @title = t('page.circulation')
  end
  
  def statistics
    @title = t('page.statistics')
  end
  
  def acquisition
    @title = t('page.acquisition')
    #@resource = Resource.new
    #@manifestation_forms = ManifestationForm.find(:all, :order => 'position')
    #@languages = Language.find(:all, :order => 'position')
  end

  def management
    @title = t('page.management')
  end
  
  def subject
    @title = t('page.subject')
  end
  
  def configuration
    @title = t('page.configuration')
  end

  def import
    @title = t('page.import')
  end
  
  def export
    @title = t('page.export')
  end
  
  def about
    @title = t('page.about_this_system')
  end

  def add_on
    @title = t('page.add_on')
  end

  def under_construction
    @title = t('page.under_construction')
  end

  def service
  end

  private
  def get_user
    @user = current_user if logged_in?
  end
  
end
