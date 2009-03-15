# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #include TagsHelper
  include UsersHelper

  def library_system_name
    h(LibraryGroup.config.name)
  end
  
  def form_icon(manifestation_form)
    case manifestation_form.name
    when 'print'
      image_tag('/icons/book.png', :size => '16x16', :alt => manifestation_form.display_name)
    when 'CD'
      image_tag('/icons/cd.png', :size => '16x16', :alt => manifestation_form.display_name)
    when 'DVD'
      image_tag('/icons/dvd.png', :size => '16x16', :alt => manifestation_form.display_name)
    when 'file'
      image_tag('/icons/monitor.png', :size => '16x16', :alt => manifestation_form.display_name)
    else
      image_tag('/icons/help.png', :size => '16x16', :alt => 'unknown')
    end
  rescue
    image_tag('/icons/help.png', :size => '16x16', :alt => 'unknown')
  end

  def expression_form_icon(expression_form)
    case expression_form.name
    when 'text'
      image_tag('/icons/page_white_text.png', :size => '16x16', :alt => expression_form.display_name)
    when 'picture'
      image_tag('/icons/picture.png', :size => '16x16', :alt => expression_form.display_name)
    when 'sound'
      image_tag('/icons/sound.png', :size => '16x16', :alt => expression_form.display_name)
    when 'video'
      image_tag('/icons/film.png', :size => '16x16', :alt => expression_form.display_name)
    else
      image_tag('/icons/help.png', :size => '16x16', :alt => ('unknown'))
    end
  rescue
    image_tag('/icons/help.png', :size => '16x16', :alt => ('unknown'))
  end

  def patron_type_icon(patron_type)
    case patron_type
    when 'Person'
      image_tag('/icons/user.png', :size => '16x16', :alt => ('Person'))
    when 'CorporateBody'
      image_tag('/icons/group.png', :size => '16x16', :alt => ('CorporateBody'))
    end
  rescue
    image_tag('/icons/help.png', :size => '16x16', :alt => ('unknown'))
  end

  def serial_title_link(manifestation)
    # FIXME: 最初の1誌だけが取得されるが…
    link_to h(manifestation.serial.original_title), expression_path(manifestation.serial)
  rescue
    nil
  end

  def link_to_tag(tag)
    link_to h(tag), manifestations_path(:tag => tag.name)
  end

  def tag_cloud(tags, options = {})
    return nil if tags.nil?
    # TODO: add options to specify different limits and sorts
    #tags = Tag.find(:all, :limit => 100, :order => 'taggings_count DESC').sort_by(&:name)
    
    # TODO: add option to specify which classes you want and overide this if you want?
    classes = %w(popular v-popular vv-popular vvv-popular vvvv-popular)
    
    max, min = 0, 0
    tags.each do |tag|
      #if options[:max] or options[:min]
      #  max = options[:max].to_i
      #  min = options[:min].to_i
      #end
      max = tag.taggings_count if tag.taggings_count.to_i > max
      min = tag.taggings_count if tag.taggings_count.to_i < min
    end
    divisor = ((max - min) / classes.size) + 1
    
    html =    %(<div class="hTagcloud">\n)
    html <<   %(  <ul class="popularity">\n)
    tags.each do |tag|
      html << %(  <li>)
      html << link_to(h(tag.name), manifestations_url(:tag => tag.name), :class => classes[(tag.taggings_count - min) / divisor]) 
      html << %(  </li>\n) # FIXME: IEのために文末の空白を入れている
    end
    html <<   %(  </ul>\n)
    html <<   %(</div>\n)
  end

  def page_tag
    bookmarked_resource = BookmarkedResource.find_by_url(request.url)
    unless bookmarked_resource.blank?
      bookmarks = Bookmark.find(:all, :conditions => ['bookmarked_resource_id = ?', bookmarked_resource.id], :include => :tags)
      tags = []
      bookmarks.each do |bookmark|
        bookmark.tags.each do |tag|
          tags << tag
        end
        tags.uniq!
      end
      tag_cloud(tags)
    end
  end

  def patrons_list(patrons = [], options = {})
    patrons_list = []
    patrons.each do |patron|
      if options[:nolink]
        patrons_list << h(patron.full_name)
      else
        patrons_list << link_to(h(patron.full_name), patron)
      end
    end
    return patrons_list.join(" ")
  rescue
    nil
  end

  def make_manifestations_link(manifestations)
    manifestations_link = []
    manifestations.each do |manifestation|
      manifestations_link << link_to(h(manifestation.original_title), manifestation)
    end
    return manifestations_link.join(" ")
  end

  def book_jacket(manifestation)
    return nil if manifestation.nil?
    book_jacket = manifestation.amazon_book_jacket
    unless book_jacket['asin'].blank?
      link_to image_tag(book_jacket['url'], :width => book_jacket['width'], :height => book_jacket['height'], :alt => manifestation.original_title, :border => 0), "http://www.amazon.co.jp/dp/#{book_jacket['asin']}"
    else
      unless manifestation.access_address.blank?
        #link_to image_tag("http://api.thumbalizr.com/?url=#{manifestation.access_address}&width=180", :width => 180, :height => 144, :alt => manifestation.original_title, :border => 0), manifestation.access_address
        #link_to image_tag("http://capture.heartrails.com/medium?#{manifestation.access_address}", :width => 200, :height => 150, :alt => manifestation.original_title, :border => 0), manifestation.access_address
        # TODO: Project Next-L 専用のMozshotサーバを作る
        link_to image_tag("http://mozshot.nemui.org/shot?#{manifestation.access_address}", :width => 128, :height => 128, :alt => manifestation.original_title, :border => 0), manifestation.access_address
      else
        image_tag(book_jacket['url'], :width => book_jacket['width'], :height => book_jacket['height'], :alt => ('no image'), :border => 0)
      end
    end
  rescue
    nil
  end

  def advertisement_pickup
    advertisement = Advertisement.pickup
    unless advertisement.url.blank?
      link_to h(advertisement.body), advertisement.url
    else
      h(advertisement.body)
    end
  rescue
    nil
  end

  def database_adapter
    case ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
    when 'postgresql'
      link_to 'PostgreSQL', 'http://www.postgresql.org/'
    when 'mysql'
      link_to 'MySQL', 'http://www.mysql.org/'
    when 'sqlite3'
      link_to 'SQLite', 'http://www.sqlite.org/'
    end
  end

  def title_action_name
    case controller.action_name
    when 'index'
      t('title.index')
    when 'show'
      t('title.show')
    when 'new'
      t('title.new')
    when 'edit'
      t('title.edit')
    end
  end

  def link_to_wikipedia(string)
    link_to ('Wikipedia'), "http://#{I18n.default_locale}.wikipedia.org/wiki/#{CGI.escape(string)}"
  end
end
