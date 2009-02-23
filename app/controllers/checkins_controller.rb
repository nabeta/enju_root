class CheckinsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?
  before_filter :get_user_if_nil
  before_filter :get_basket
  
  # GET /checkins
  # GET /checkins.xml
  def index
    # かごがない場合、自動的に作成する
    unless @basket
      @basket = Basket.create!(:user => current_user)
      redirect_to user_basket_checkins_url(@basket.user.login, @basket)
      return
    end
    @checkins = @basket.checkins.find(:all, :order => ['checkins.created_at DESC'])

    if params[:mode] == 'list'
      render :partial => 'list'
      return
    end

    @checkin = @basket.checkins.new

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @checkins.to_xml }
    end
  end

  # GET /checkins/1
  # GET /checkins/1.xml
  def show
    @checkin = Checkin.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @checkin.to_xml }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /checkins/new
  def new
    #@checkin = @basket.checkins.new
    redirect_to checkins_url
  end

  # GET /checkins/1;edit
  def edit
    @checkin = Checkin.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /checkins
  # POST /checkins.xml
  def create
    item_identifier = params[:checkin][:item_identifier].to_s.strip
    unless item_identifier.blank?
      #item = Item.find(:first, :conditions => {:item_identifier => item_identifier})
      item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ? LIMIT 1', item_identifier]).first
    end

    flash[:message] = []
    unless item.blank?
      if @basket.checkins.collect(&:item).include?(item)
        redirect_to user_basket_checkins_url(@basket.user.login, @basket, :mode => 'list')
        flash[:message] << t('checkin.already_checked_in')
        return
      end
      @checkin = @basket.checkins.new(params[:checkin])
      @checkin.item = item

      respond_to do |format|
        if @checkin.save
          flash[:message] << t('controller.successfully_created', :model => t('activerecord.models.checkin'))
          Checkin.transaction do
            checkout = Checkout.find(:first, :conditions => {:item_id => @checkin.item.id})
            # TODO: 貸出されていない本の処理
            # TODO: ILL時の処理
            @checkin.item.checkin!
            @checkin.checkout = checkout if checkout

            unless checkout.other_library_resource?(current_user.library)
              flash[:message] << t('checkin.other_library_item')
            end
            #unless checkout.user.save_checkout_history
            #  checkout.user = nil
            #end
            if @checkin.item.reserved?
              # TODO: もっと目立たせるために別画面を表示するべき？
              flash[:message] << t('item.this_item_is_reserved')
              @checkin.item.retain(current_user)
            end

            if @checkin.item.include_supplements?
              flash[:message] << t('item.this_item_include_supplement')
            end

            # メールとメッセージの送信
            #ReservationNotifier.deliver_reserved(@checkin.item.manifestation.reserves.first.user, @checkin.item.manifestation)
            #Message.create(:sender => current_user, :receiver => @checkin.item.manifestation.next_reservation.user, :subject => message_template.title, :body => message_template.body, :recipient => @checkin.item.manifestation.next_reservation.user.login)
          end
        
          if params[:mode] == 'list'
            redirect_to(user_basket_checkins_url(@checkin.basket.user.login, @checkin.basket, :mode => 'list'))
            return
          else
            format.html { redirect_to user_basket_checkins_url(@checkin.basket.user.login, @checkin.basket) }
            format.xml  { render :xml => @checkin, :status => :created, :location => user_basket_checkin_url(@checkin.basket.user.login, @checkin.basket, @checkin) }
          end
        else
          if params[:mode] == 'list'
            redirect_to user_basket_checkins_url(@basket.user.login, @basket, :mode => 'list')
            return
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @checkin.errors.to_xml }
          end
        end
      end
    else
      flash[:message] << t('checkin.enter_item_identifier')
      if params[:mode] == 'list'
        redirect_to user_basket_checkins_url(@basket.user.login, @basket, :mode => 'list')
      else
        redirect_to user_basket_checkins_url(@basket.user.login, @basket)
      end
    end
  end

  # PUT /checkins/1
  # PUT /checkins/1.xml
  def update
    item_identifier = params[:checkin][:item_identifier].to_s.strip
    unless item_identifier.blank?
      #item = Item.find(:first, :conditions => {:item_identifier => item_identifier})
      item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ? LIMIT 1', item_identifier]).first
    end
    @checkin = Checkin.find(params[:id])
    @checkin.item = item

    respond_to do |format|
      if @checkin.update_attributes(params[:checkin])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkin'))
        format.html { redirect_to checkin_url(@checkin) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkin.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /checkins/1
  # DELETE /checkins/1.xml
  def destroy
    @checkin = Checkin.find(params[:id])
    @checkin.destroy

    respond_to do |format|
      format.html { redirect_to checkins_url }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end
end
