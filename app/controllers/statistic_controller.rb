class StatisticController < ApplicationController
  before_filter :set_date

  def index
  end

  def user
    case params[:report]
    when 'checked_out'
      checkouts = Checkout.completed(@from_date_stat, @to_date_stat)
      begin
        user_ids = checkouts.collect(&:user).inject(Hash.new(0)){|r,e|r[e]+=1;r}.to_a.collect{|q| q if q[1] >= 1}.compact.collect{|u| u.first.id}
        @users = User.paginate(user_ids, :page => params[:per_page])
      end
      #@users = User.paginate(:all, :page => params[:page], :include => [:checkouts], :conditions => ['users.checkouts.size > 0 AND checkouts.created_at >= ? AND checkouts.created_at < ?', @from_date_stat, @to_date_stat], :order => 'users.checkouts_count DESC, users.id')
      render :template => 'statistic/user/checked_out'
    else
      # TODO
    end
  end

  def bookmark
    if params[:period] == 'all'
      conditions = ['bookmarked_resources.bookmarks_count > 0 ']
    else
      conditions = ['bookmarked_resources.bookmarks_count > 0 AND bookmarks.created_at >= ? AND bookmarks.created_at < ?', @from_date_stat, @to_date_stat]
    end
    case params[:report]
    when 'most_bookmarked'
      #@bookmarked_resources = BookmarkedResource.paginate(:all, :page => params[:page], :include => [:bookmarks], :conditions => conditions, :order => 'bookmarked_resources.bookmarks_count DESC, bookmarked_resources.id')
      #@bookmarked_resources = BookmarkedResource.paginate_by_sql(['SELECT bookmarked_resource_id, count from (select bookmarked_resource_id, count(bookmarked_resource_id) from bookmarks where created_at >= ? created_at < ? AND  group by bookmarked_resource_id) as bookmark_count;]', @from_date_stat, @to_date_stat)

      @bookmarked_resources = BookmarkedResource.paginate_by_sql(['SELECT * FROM bookmarked_resources WHERE id IN (SELECT id FROM (SELECT bookmarked_resource_id AS id, count(bookmarked_resource_id) FROM bookmarks WHERE created_at >= ? AND created_at < ? GROUP BY bookmarked_resource_id) AS bookmark_count) ORDER BY bookmarks_count DESC, id', @from_date_stat, @to_date_stat], :page => params[:page])
      render :template => 'statistic/bookmark/most_bookmarked'
    else
      # TODO
    end
  end

  def manifestation
    case params[:report]
    when 'most_checked_out'
      @manifestations = Manifestation.paginate(:all, :page => params[:page], :include => [:items => :checkouts], :conditions => ['items.checkouts_count > 0 AND checkouts.created_at >= ? AND checkouts.created_at < ?', @from_date_stat, @to_date_stat], :order => 'items.checkouts_count DESC, manifestations.id')
      render :template => 'statistic/manifestation/most_checked_out'
    else
      # TODO
    end
  end

  private
  def set_date
    if params[:stat_from]
      @from_date = Time.gm(params[:stat_from][:year].to_i, params[:stat_from][:month].to_i, params[:stat_from][:day].to_i) rescue nil
    elsif params[:from_date]
      @from_date = Time.parse(params[:from_date]) rescue nil
    end
    if params[:stat_to]
      @to_date = Time.gm(params[:stat_to][:year].to_i, params[:stat_to][:month].to_i, params[:stat_to][:day].to_i) rescue nil
    elsif params[:to_date]
      @to_date = Time.parse(params[:to_date]) rescue nil
    end

    @from_date = Time.zone.now.beginning_of_day if @from_date.nil?
    @to_date = 1.day.from_now.beginning_of_day if @to_date.nil?

    @from_date_stat = @from_date.beginning_of_day
    @to_date_stat = @to_date.tomorrow.beginning_of_day
  end
end
