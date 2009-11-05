# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include UsersHelper

  def library_system_name
    h(LibraryGroup.site_config.name)
  end
  
  def form_icon(carrier_type)
    case carrier_type.name
    when 'print'
      image_tag('/icons/book.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'CD'
      image_tag('/icons/cd.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'DVD'
      image_tag('/icons/dvd.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    when 'file'
      image_tag('/icons/monitor.png', :size => '16x16', :alt => carrier_type.display_name.localize)
    else
      image_tag('/icons/help.png', :size => '16x16', :alt => 'unknown')
    end
  rescue
    image_tag('/icons/help.png', :size => '16x16', :alt => 'unknown')
  end

  def content_type_icon(content_type)
    case content_type.name
    when 'text'
      image_tag('/icons/page_white_text.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'picture'
      image_tag('/icons/picture.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'sound'
      image_tag('/icons/sound.png', :size => '16x16', :alt => content_type.display_name.localize)
    when 'video'
      image_tag('/icons/film.png', :size => '16x16', :alt => content_type.display_name.localize)
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
    link_to h(manifestation.original_title), manifestation_path(manifestation)
  rescue
    nil
  end

  def link_to_tag(tag)
    link_to h(tag), manifestations_path(:tag => tag.name)
  end

  def render_tag_cloud(tags, options = {})
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

  def patrons_list(patrons = [], user = nil, options = {})
    return nil if patrons.blank?
    patrons_list = []
    if options[:nolink]
      patrons_list = patrons.map{|patron| h(patron.full_name) if patron.is_readable_by(user)}
    else
      patrons_list = patrons.map{|patron| link_to(h(patron.full_name), patron) if patron.is_readable_by(user)}
    end
    patrons_list.join(" ")
  end

  def book_jacket(manifestation)
    return nil if manifestation.nil?
    book_jacket = manifestation.amazon_book_jacket
    unless book_jacket.blank?
      unless book_jacket['asin'].blank?
        link_to image_tag(book_jacket['url'], :width => book_jacket['width'], :height => book_jacket['height'], :alt => manifestation.original_title, :class => 'book_jacket'), "http://www.amazon.com/dp/#{book_jacket['asin']}"
      else
        if manifestation.screen_shot.present?
        #link_to image_tag("http://api.thumbalizr.com/?url=#{manifestation.access_address}&width=180", :width => 180, :height => 144, :alt => manifestation.original_title, :border => 0), manifestation.access_address
        #link_to image_tag("http://capture.heartrails.com/medium?#{manifestation.access_address}", :width => 200, :height => 150, :alt => manifestation.original_title, :border => 0), manifestation.access_address
        # TODO: Project Next-L 専用のMozshotサーバを作る
          link_to image_tag(manifestation_path(manifestation, :mode => 'screen_shot'), :width => 128, :height => 128, :alt => manifestation.original_title, :class => 'screen_shot'), manifestation.access_address
        else
          image_tag(book_jacket['url'], :width => book_jacket['width'], :height => book_jacket['height'], :alt => ('no image'), :class => 'book_jacket')
        end
      end
    end
  rescue
    nil
  end

  def advertisement_pickup(advertisement)
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
    link_to ('Wikipedia'), "http://#{I18n.locale}.wikipedia.org/wiki/#{URI.escape(string)}"
  end

  def locale_display_name(locale)
    h(Language.find(:first, :conditions => {:iso_639_1 => locale}).display_name)
  end

  def locale_native_name(locale)
    h(Language.find(:first, :conditions => {:iso_639_1 => locale}).native_name)
  end

  def move_position(object)
    render :partial => 'page/position', :locals => {:object => object}
  end

end
