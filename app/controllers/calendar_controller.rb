class CalendarController < ApplicationController
  before_filter :get_library
  
  def index
    @month = params[:month].to_i
    @year = params[:year].to_i

    #@shown_month = Date.civil(@year, @month)
    @shown_month = Time.zone.local(@year, @month, 1) rescue Time.zone.now

    # TODO: Solrを使って取得
    if @library
      @event_strips = Event.at(@library).event_strips_for_month(@shown_month)
    else
      @event_strips = Event.event_strips_for_month(@shown_month)
    end
  end
  
end
