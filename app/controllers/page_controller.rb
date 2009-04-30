class PageController < ApplicationController
  before_filter :store_location, :except => [:opensearch, :sitemap, :screen_shot]
  #before_filter :login_required, :except => [:index, :advanced_search, :opensearch, :about, :message]
  before_filter :require_user, :except => [:index, :advanced_search, :opensearch, :about, :message, :screen_shot]
  before_filter :get_libraries, :only => [:advanced_search]
  before_filter :get_user # 上書き注意
  require_role 'Librarian', :except => [:index, :advanced_search, :opensearch, :sitemap, :about, :message, :screen_shot]

  caches_page :opensearch, :sitemap

  def index
    if logged_in?
      redirect_to user_url(current_user.login)
    end
    @numdocs = Manifestation.cached_numdocs
    # TODO: タグ下限の設定
    @tags = Tag.find(:all, :limit => 50, :order => 'taggings_count DESC')
    @manifestation = Manifestation.pickup
    @news_feeds = LibraryGroup.site_config.news_feeds rescue nil
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
  
  def opensearch
    render :layout => false
  end

  def sitemap
    render :layout => false
  end

  def about
    @title = t('page.about_this_system')
  end

  def under_construction
    @title = t('page.under_construction')
  end

  def screen_shot
    thumb = Page.get_screen_shot(params[:url])
    if thumb
      file = Tempfile.new('thumb')
      file.puts thumb
      file.close
      mime = MIME.check(file.path)
      send_data thumb, :filename => File.basename(file.path), :type => mime.type, :disposition => 'inline'
    end
  end

  private
  def get_user
    @user = current_user if logged_in?
  end
  
end
