class CalendarController < ApplicationController
  
  def index
    @month = params[:month].to_i
    @year = params[:year].to_i

    #@shown_month = Date.civil(@year, @month)
    @shown_month = Time.zone.parse("#{@year}-#{@month}-01")

    @event_strips = Event.event_strips_for_month(@shown_month)
  end
  
end
