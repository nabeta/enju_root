class PageController < ApplicationController
  before_filter :store_location, :except => [:opensearch]
  before_filter :login_required, :except => [:index, :advanced_search, :opensearch, :about, :message]
  before_filter :get_libraries, :only => [:advanced_search]
  before_filter :get_user # 上書き注意
  require_role 'Librarian', :except => [:index, :advanced_search, :opensearch, :about, :message]

  caches_page :opensearch

  def index
    if logged_in?
      redirect_to user_url(current_user.login)
    end
    @numdocs = Manifestation.numdocs
    # TODO: タグ下限の設定
    @tags = Tag.find(:all, :limit => 50, :order => 'taggings_count DESC')
    @picked_up = Manifestation.pickup
    @news_feeds = LibraryGroup.find(:first).news_feeds.find(:all, :order => :position) rescue nil
  end

  def patron
    @title = ('Patron')
  end
  
  def advanced_search
    @title = ('Advanced search')
  end

  def message
    if logged_in?
      redirect_to inbox_user_messages_url(current_user.login)
    else
      redirect_to new_session_url
    end
  end

  def circulation
    @title = ('Circulation')
  end
  
  def statistics
  end
  
  def acquisition
    @title = ('Acquisition')
  end

  def management
    @title = ('Management')
  end
  
  def configuration
    @title = ('Configuration')
  end

  def import
    @title = ('Import')
  end
  
  def export
    @title = ('Export')
  end
  
  def opensearch
    render :layout => false
  end

  def about
    @title = ('About us')
  end

  def under_construction
    @title = ('Under construction')
  end

  private
  def get_user
    @user = current_user if logged_in?
  end
  
end

