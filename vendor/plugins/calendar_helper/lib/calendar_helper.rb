require 'date'
 
# CalendarHelper allows you to draw a databound calendar with fine-grained CSS formatting
module CalendarHelper
  VERSION = '0.3.2'
  # Returns an HTML calendar. In its simplest form, this method generates a plain
  # calendar (which can then be customized using CSS).
  # However, this may be customized in a variety of ways -- changing the default CSS
  # classes, generating the individual day entries yourself, and so on.
  #
  # The following are optional, available for customizing the default behaviour:
  # :month => Time.now.month # The month to show the calendar for. Defaults to current month.
  # :year => Time.now.year # The year to show the calendar for. Defaults to current year.
  # :table_class => "calendar" # The class for the <table> tag.
  # :month_name_class => "monthName" # The class for the name of the month, at the top of the table.
  # :other_month_class => "otherMonth" # Not implemented yet.
  # :day_name_class => "dayName" # The class is for the names of the weekdays, at the top.
  # :day_class => "day" # The class for the individual day number cells.
  # This may or may not be used if you specify a block (see below).
  # :abbrev => (0..2) # This option specifies how the day names should be abbreviated.
  # Use (0..2) for the first three letters, (0..0) for the first, and
  # (0..-1) for the entire name.
  # :first_day_of_week => 0 # Renders calendar starting on Sunday. Use 1 for Monday, and so on.
  # :accessible => true # Turns on accessibility mode. This suffixes dates within the
  # # calendar that are outside the range defined in the <caption> with
  # # <span class="hidden"> MonthName</span>
  # # Defaults to false.
  # # You'll need to define an appropriate style in order to make this disappear.
  # # Choose your own method of hiding content appropriately.
  #
  # :show_today => false # Highlights today on the calendar using the CSS class 'today'.
  # # Defaults to true.
  # :month_name_text => nil # Displayed center in header row. Defaults to current month name from Date::MONTHNAMES hash.
  # :previous_month_text => nil # Displayed left of the month name if set
  # :next_month_text => nil # Displayed right of the month name if set
  #
  # For more customization, you can pass a code block to this method, that will get one argument, a Date object,
  # and return a values for the individual table cells. The block can return an array, [cell_text, cell_attrs],
  # cell_text being the text that is displayed and cell_attrs a hash containing the attributes for the <td> tag
  # (this can be used to change the <td>'s class for customization with CSS).
  # This block can also return the cell_text only, in which case the <td>'s class defaults to the value given in
  # +:day_class+. If the block returns nil, the default options are used.
  #
  # Example usage:
  # calendar # This generates the simplest possible calendar with the curent month and year.
  # calendar({:year => 2005, :month => 6}) # This generates a calendar for June 2005.
  # calendar({:table_class => "calendar_helper"}) # This generates a calendar, as
  # # before, but the <table>'s class
  # # is set to "calendar_helper".
  # calendar(:abbrev => (0..-1)) # This generates a simple calendar but shows the
  # # entire day name ("Sunday", "Monday", etc.) instead
  # # of only the first three letters.
  # calendar do |d| # This generates a simple calendar, but gives special days
  # if listOfSpecialDays.include?(d) # (days that are in the array listOfSpecialDays) one CSS class,
  # [d.mday, {:class => "specialDay"}] # "specialDay", and gives the rest of the days another CSS class,
  # else # "normalDay". You can also use this highlight today differently
  # [d.mday, {:class => "normalDay"}] # from the rest of the days, etc.
  # end
  # end
  #
  # An additional 'weekend' class is applied to weekend days.
  #
  # For consistency with the themes provided in the calendar_styles generator, use "specialDay" as the CSS class for marked days.
  #
  def calendar(options = {}, &block)
    block ||= Proc.new {|d| nil}
 
    defaults = {

      :year                 => Time.now.year,
      :month                => Time.now.month,
      :table_class          => 'calendar',
      :month_name_class     => 'monthName',
      :other_month_class    => 'otherMonth',
      :day_name_class       => 'dayName',
      :day_class            => 'day',
      :abbrev               => (0..2),
      :first_day_of_week    => 0,
      :accessible           => false,
      :show_today           => true,
      :show_year            => false,
      :previous_month_text  => nil,
      :previous_month_class => 'prevMonth',
      :next_month_text      => nil,
      :next_month_class     => 'nextMonth'
    }
    options = defaults.merge options
    
    month_names = t('date.month_names') || Date::MONTHNAMES
    options[:month_name_text] ||= month_names[options[:month]]
    options[:month_name_text] += " #{options[:year]}" if options[:show_year]

    first = Date.civil(options[:year], options[:month], 1)
    last = Date.civil(options[:year], options[:month], -1)
 
    first_weekday = first_day_of_week(options[:first_day_of_week])
    last_weekday = last_day_of_week(options[:first_day_of_week])
    
    day_names = (t('date.day_names') || Date::DAYNAMES).dup
    first_weekday.times do
      day_names.push(day_names.shift)
    end
 
    # TODO Use some kind of builder instead of straight HTML
    cal = %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">)
    cal << %(<thead><tr>)
    if options[:previous_month_text] or options[:next_month_text]
      cal << %(<th colspan="2" class="#{options[:previous_month_class]}">#{options[:previous_month_text]}</th>)
      colspan=3
    else
      colspan=7
    end
    cal << %(<th colspan="#{colspan}" class="#{options[:month_name_class]}">#{options[:month_name_text]}</th>)
    cal << %(<th colspan="2" class="#{options[:next_month_class]}">#{options[:next_month_text]}</th>) if options[:next_month_text]
    cal << %(</tr><tr class="#{options[:day_name_class]}">)
    day_names.each do |d|
      unless d[options[:abbrev]].eql? d
        cal << "<th scope='col'><abbr title='#{d}'>#{d[options[:abbrev]]}</abbr></th>"
      else
        cal << "<th scope='col'>#{d[options[:abbrev]]}</th>"
      end
    end
    cal << "</tr></thead><tbody><tr>"
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      # Allow items to be displayed on the previous month days that fall
      # on the first week of the month calendar.
      cell_text, cell_attrs = block.call(d)
      if options[:accessible]
        cell_text ||= "#{d.mday}<span class='hidden'> #{Date::MONTHNAMES[d.month]}</span>"
      else
        cell_text ||= "#{d.mday}"
      end
      cell_attrs ||= {:class => options[:day_class]}
      cell_attrs[:class] += " #{options[:other_month_class]}"
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(d.wday) 
      cell_attrs[:class] += " firstDay" if d.wday == first_weekday
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
    end unless first.wday == first_weekday
    first.upto(last) do |cur|
      cell_text, cell_attrs = block.call(cur)
      cell_text ||= cur.mday
      cell_attrs ||= {:class => options[:day_class]}
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday) 
      cell_attrs[:class] += " today" if (cur == Date.today) and options[:show_today] 
      cell_attrs[:class] += " firstDay" if cur.wday == first_weekday 
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
      cal << "</tr><tr>" if cur.wday == last_weekday
    end
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      # Allow items to be displayed of the next month days that fall
      # on the last week of the month calendar.
      cell_text, cell_attrs = block.call(d)
      if options[:accessible]
        cell_text ||= "#{d.mday}<span class='hidden'> #{Date::MONTHNAMES[d.month]}</span>"
      else
        cell_text ||= "#{d.mday}"
      end
      cell_attrs ||= {:class => options[:day_class]}
      cell_attrs[:class] += " #{options[:other_month_class]}"
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(d.wday) 
      cell_attrs[:class] += " firstDay" if d.wday == first_weekday
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
    end unless last.wday == last_weekday
    # If the last day of the month is also the last day of the weed then we 
    # have an open row that needs to be removed, otherwise we have a week row 
    # that now needs to be closed.
    last.wday == last_weekday ? cal.chomp!("<tr>") : cal << "</tr>"
    cal << "</tbody></table>"
  end
  
  private
  
  def first_day_of_week(day)
    day
  end
  
  def last_day_of_week(day)
    if day > 0
      day - 1
    else
      6
    end
  end
  
  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end
  
  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end
  
  def weekend?(date)
    [0, 6].include?(date.wday)
  end
  
end