class PageController < ApplicationController
  before_filter :clear_search_sessions, :only => [:index, :advanced_search]
  before_filter :store_location, :only => [:advanced_search, :about, :add_on, :msie_acceralator, :statistics]
  before_filter :authenticate_user!, :except => [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch, :statistics, :routing_error]
  before_filter :check_librarian, :except => [:index, :advanced_search, :about, :add_on, :msie_acceralator, :opensearch, :statistics, :routing_error]
  helper_method :get_libraries

  def index
    if user_signed_in?
      session[:user_return_to] = nil
      unless current_user.patron
        redirect_to new_user_patron_url(current_user); return
      end
      @manifestation = Manifestation.pickup(current_user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil
    else
      @manifestation = Manifestation.pickup rescue nil
    end
    get_top_page_content
    @numdocs = Manifestation.search.total

    respond_to do |format|
      format.html
      format.json { render :json => user }
    end
  end

  def msie_acceralator
    render :layout => false
  end

  def opensearch
    render :layout => false
  end

  def advanced_search
    get_libraries
    @title = t('page.advanced_search')
  end

  def statistics
    @title = t('page.statistics')
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

  def routing_error
    render_404
  end

  private
  def check_librarian
    unless current_user.has_role?('Librarian')
      access_denied
    end
  end
end
