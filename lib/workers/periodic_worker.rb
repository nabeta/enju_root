class PeriodicWorker < BackgrounDRb::MetaWorker
  set_worker_name :periodic_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def send_messages(args = nil)
    MessageQueue.not_sent.each do |queue|
      queue.send_message
    end
    logger.info "#{Time.zone.now} sent messages!"
  #rescue
  #  logger.info "#{Time.zone.now} sending messages failed!"
  end

  def fetch_feeds(args = nil)
    require 'action_controller/integration'
    app = ActionController::Integration::Session.new
    app.host = LIBRARY_WEB_HOSTNAME
    NewsFeed.find(:all).each do |news_feed|
      news_feed.force_reload
    end
    app.get('/news_feeds?mode=clear_cache')
    logger.info "#{Time.zone.now} feeds reloaded!"
  rescue
    logger.info "#{Time.zone.now} reloading feeds failed!"
  end

  def solr_reindex(args = nil)
    Patron.rebuild_solr_index(500)
    Work.rebuild_solr_index(500)
    Expression.rebuild_solr_index(500)
    Manifestation.rebuild_solr_index(500)
    Item.rebuild_solr_index(500)
    logger.info "#{Time.zone.now} optimized!"
  rescue StandardError, Timeout::Error
    logger.info "#{Time.zone.now} optimization failed!"
  end

  def expire_aaws_responses(args = nil)
    AawsResponse.delete_all(['created_at < ?', 30.days.from_now])
    logger.info "#{Time.zone.now} aaws responses expired!"
  rescue
    logger.info "#{Time.zone.now} expiring aaws responses failed!"
  end

  def expire_reservations(args = nil)
    reservations = Reserve.will_expire(Time.zone.now.beginning_of_day)
    reservations.each do |reserve|
      reserve.aasm_expire!
      #reserve.expire
      reserve.send_message('expired')
    end
    Reserve.send_message_to_patrons('expired') unless reservations.blank?
    logger.info "#{Time.zone.now} #{reservations.size} reservations expired!"
  #rescue
  #  logger.info "#{Time.zone.now} expiring reservations failed!"
  end

  def expire_baskets(args = nil)
    Basket.will_expire(Time.zone.now.beginning_of_day).destroy_all
    logger.info "#{Time.zone.now} baskets expired!"
  rescue
    logger.info "#{Time.zone.now} expiring baskets failed!"
  end

  def expire_sessions(date)
    Session.sweep(date)
    logger.info "#{Time.zone.now} sessions expired!"
  rescue
    logger.info "#{Time.zone.now} expiring sessions failed!"
  end

  def import_patrons
    ImportedPatronFile.not_imported.each do |file|
      file.import
    end
  rescue
    logger.info "#{Time.zone.now} importing patrons failed!"
  end

  def import_events
    ImportedEventFile.not_imported.each do |file|
      file.import
    end
  rescue
    logger.info "#{Time.zone.now} importing events failed!"
  end

  def import_resources
    ImportedResourceFile.not_imported.each do |file|
      file.import
    end
  rescue
    logger.info "#{Time.zone.now} importing resources failed!"
  end

  def culculate_checkouts_count(from_date, to_date)
    manifestation_stat = CheckoutStat.create(:from_date => from_date, :to_date => to_date)
    manifestation_stat.culculate_manifestations_count
  end

  def culculate_bookmarks_count(from_date, to_date)
    bookmark_stat = BookmarkStat.create(:from_date => from_date, :to_date => to_date)
    bookmark_stat.culculate_bookmarks_count
  end
end
