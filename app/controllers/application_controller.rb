#require "ruby-prof"
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #helper_method :logged_in?

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  # Pick a unique cookie name to distinguish our session data from others'
  #include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include SslRequirement

  include ExceptionNotification::Notifiable

  filter_parameter_logging :password, :password_confirmation, :current_password, :full_name, :address, :date_of_birth, :date_of_death, :zip_code, :checkout_icalendar_token

  before_filter :get_library_group, :set_locale, :set_available_languages,
    :pickup_advertisement
  #before_filter :has_permission?

  private
  def get_library_group
    @library_group = LibraryGroup.site_config
  end

  def set_locale
    if Rails.env == 'test'
      locale = 'en'
    else
      if logged_in?
        locale = params[:locale] || session[:locale] || current_user.locale || I18n.default_locale.to_s
      else
        locale = params[:locale] || session[:locale] || I18n.default_locale.to_s
      end
    end
    unless I18n.available_locales.include?(locale.intern)
      locale = I18n.default_locale.to_s
    end
    I18n.locale = locale
    @locale = session[:locale] = locale
  rescue
    I18n.locale = I18n.default_locale
    @locale = I18n.locale.to_s
  end

  def default_url_options(options={})
    {:locale => nil}
  end

  def set_available_languages
    @available_languages = Language.available_languages
  end

  def reset_params_session
    session[:params] = nil
  end

  def not_found
    render(:file => "#{Rails.root}/public/404.html", :status => "404 Not Found")
    return
  end

  def logged_in?
    !!current_user
  end

  def access_denied
    respond_to do |format|
      format.html do
        store_location
        if logged_in?
          render(:file => "#{Rails.root}/public/403.html", :status => "403 Forbidden")
        else
          redirect_to new_user_session_url
          #render(:file => "#{Rails.root}/public/401.html", :status => "401 Unauthorized")
        end
      end
      # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
      # you may want to change format.any to e.g. format.any(:js, :xml)
      format.any(:json, :xml) do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  def get_patron
    @patron = Patron.find(params[:patron_id]) if params[:patron_id]
    access_denied unless @patron.is_readable_by(current_user) if @patron
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_work
    @work = Work.find(params[:work_id]) if params[:work_id]
    access_denied unless @work.is_readable_by(current_user) if @work
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_item
    @item = Item.find(params[:item_id]) if params[:item_id]
    access_denied unless @item.is_readable_by(current_user) if @item
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_expression
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    access_denied unless @expression.is_readable_by(current_user) if @expression
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_manifestation
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    access_denied unless @manifestation.is_readable_by(current_user) if @manifestation
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_carrier_type
    @carrier_type = CarrierType.find(params[:carrier_type_id]) if params[:carrier_type_id]
  end

  def get_shelf
    @shelf = Shelf.find(params[:shelf_id], :include => :library) if params[:shelf_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_basket
    @basket = Basket.find(params[:basket_id]) if params[:basket_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_patron_merge_list
    @patron_merge_list = PatronMergeList.find(params[:patron_merge_list_id]) if params[:patron_merge_list_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_work_merge_list
    @work_merge_list = WorkMergeList.find(params[:work_merge_list_id]) if params[:work_merge_list_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_expression_merge_list
    @expression_merge_list = ExpressionMergeList.find(params[:expression_merge_list_id]) if params[:expression_merge_list_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_user
    @user = User.first(:conditions => {:username => params[:user_id]}) if params[:user_id]
    raise ActiveRecord::RecordNotFound unless @user
    unless @user.is_readable_by(current_user)
      access_denied; return
    end
    return @user
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_user_if_nil
    @user = User.first(:conditions => {:username => params[:user_id]}) if params[:user_id]
    if @user
      access_denied unless @user.is_readable_by(current_user)
    end
  end
  
  def get_user_group
    @user_group = UserGroup.find(params[:user_group_id]) if params[:user_group_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end
                    
  def get_library
    @library = Library.find(params[:library_id]) if params[:library_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_libraries
    @libraries = Library.all
  end

  def get_library_group
    @library_group = LibraryGroup.site_config
  end

  def get_question
    @question = Question.find(params[:question_id]) if params[:question_id]
    access_denied unless @question.is_readable_by(current_user) if @question
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_event
    @event = Event.find(params[:event_id]) if params[:event_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_bookstore
    @bookstore = Bookstore.find(params[:bookstore_id]) if params[:bookstore_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_subject
    @subject = Subject.find(params[:subject_id]) if params[:subject_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_classification
    @classification = Classification.find(params[:classification_id]) if params[:classification_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_subscription
    @subscription = Subscription.find(params[:subscription_id]) if params[:subscription_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_order_list
    @order_list = OrderList.find(params[:order_list_id]) if params[:order_list_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_purchase_request
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id]) if params[:purchase_request_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_checkout_type
    @checkout_type = CheckoutType.find(params[:checkout_type_id]) if params[:checkout_type_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_inventory_file
    @inventory_file = InventoryFile.find(params[:inventory_file_id]) if params[:inventory_file_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_subject_heading_type
    @subject_heading_type = SubjectHeadingType.find(params[:subject_heading_type_id]) if params[:subject_heading_type_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def get_series_statement
    @series_statement = SeriesStatement.find(params[:series_statement_id]) if params[:series_statement_id]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def librarian_authorized?
    return false unless logged_in?
    user = get_user_if_nil
    return true if user == current_user
    return true if current_user.has_role?('Librarian')
    false
  end

  def convert_charset
    #if params[:format] == 'ics'
    #  response.body = NKF::nkf('-w -Lw', response.body)
    case params[:format]
    when 'csv'
      return if CSV_CHARSET_CONVERSION == false
      # TODO: 他の言語
      if @locale == 'ja'
        headers["Content-Type"] = "text/csv; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    when 'xml'
      if @locale == 'ja'
        headers["Content-Type"] = "application/xml; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    end
  end

  def my_networks?
    return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'lan')
    false
  end

  def admin_networks?
    return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'admin')
    false
  end

  def check_client_ip_address
    access_denied unless my_networks?
  end

  def check_admin_network
    access_denied unless admin_networks?
  end

  def check_dsbl
    @library_group = LibraryGroup.site_config
    return true if @library_group.network_access_allowed?(request.remote_ip, :network_type => 'lan')
    begin
      dsbl_hosts = @library_group.dsbl_list.split.compact
      reversed_address = request.remote_ip.split(/\./).reverse.join(".")
      dsbl_hosts.each do |dsbl_host|
        result = Socket.gethostbyname("#{reversed_address}.#{dsbl_host}.").last.unpack("C4").join(".")
        raise SocketError unless result =~ /^127\.0\.0\./
        access_denied
      end
    rescue SocketError
      nil
    end
  end

  def store_page
    flash[:page] = params[:page].to_i if params[:page]
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def require_user
    unless current_user
      store_location
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to user_url(current_user.username)
      return false
    end
  end

  def pickup_advertisement
    if params[:format] == 'html' or params[:format].nil?
      @picked_advertisement = Advertisement.pickup
    end
  end

  def profile
    return yield if params[:profile].nil?
    result = RubyProf.profile { yield }
    printer = RubyProf::GraphPrinter.new(result)
    out = StringIO.new
    printer.print(out, 0)
    response.body.replace out.string
    response.content_type = "text/plain"
  end

  def set_role_query(user, search)
    role = user.try(:highest_role) || Role.find(1)
    search.build do
      with(:required_role_id).less_than role.id
    end
  end

  def make_internal_query(search)
    # 内部的なクエリ
    set_role_query(current_user, search)

    unless params[:mode] == "add"
      expression = @expression
      patron = @patron
      manifestation = @manifestation
      reservable = @reservable
      carrier_type = params[:carrier_type]
      library = params[:library]
      language = params[:language]
      subject = params[:subject]
      subject_by_term = Subject.first(:conditions => {:term => params[:subject]})
      @subject_by_term = subject_by_term

      search.build do
        with(:expression_ids).equal_to expression.id if expression
        with(:patron_ids).equal_to patron.id if patron
        with(:original_manifestation_ids).equal_to manifestation.id if manifestation
        with(:reservable).equal_to true if reservable
        unless carrier_type.blank?
          with(:carrier_type).equal_to carrier_type
          with(:carrier_type).equal_to carrier_type
        end
        unless library.blank?
          library_list = library.split.uniq
          library_list.each do |library|
            with(:library).equal_to library
          end
          #search.query.keywords = "#{search.query.to_params[:q]} library_s: (#{library_list})"
        end
        unless language.blank?
          language_list = language.split.uniq
          language_list.each do |language|
            with(:language).equal_to language
          end
        end
        unless subject.blank?
          with(:subject).equal_to subject_by_term.term
        end
      end
    end
    return search
  end

  def solr_commit
    Sunspot.commit
  end

  def get_version
    @version = params[:version_id].to_i if params[:version_id]
    @version = nil if @version == 0
  end

  def clear_search_sessions
    session[:query] = nil
    session[:params] = nil
    session[:search_params] = nil
    session[:manifestation_ids] = nil
  end

  def api_request?
    true unless params[:format].nil? or params[:format] == 'html'
  end
end
