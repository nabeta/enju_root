# -*- encoding: utf-8 -*-
class MessagesController < ApplicationController
  
  include RestfulEasyMessagesControllerSystem
  
  # Restful_authentication Filter
  before_filter :rezm_login_required
  before_filter :set_rezm_user
  before_filter :get_user, :only => :index
  after_filter :solr_commit, :only => [:create, :destroy]

  # GET /messages
  def index
    if params[:query]
      query = params[:query].to_s.strip
      redirect_to inbox_user_messages_url(params.merge(:query => query))
    else
      redirect_to inbox_user_messages_url
    end
  end
  
  # GET /messages/1
  def show
    @message = Message.find_by_id(params[:id])
    
    respond_to do |format|
      if can_view(@message)
        @message.mark_message_read(rezm_user)
        @message.expire_top_page_cache
        format.html # show.html.erb
      else
        headers["Status"] = "Forbidden"
        format.html {render :file => "public/403.html", :status => 403}
      end
    end
  end
  
  # GET /messages/new
  def new
    @message= Message.new
    if params[:recipient]
      @message.recipient = params[:recipient]
    end
    if @message_request = MessageRequest.find(params[:message_request_id]) rescue nil
      @message.recipient = @message_request.receiver.login
      @message.subject = @message_request.subject
      @message.body = @message_request.body
    end
  end

  # POST /messages
  def create
    @message = Message.new((params[:message] || {}).merge(:sender => rezm_user))
    @message.message_request.destroy if @message.message_request
    
    respond_to do |format|
      if @message.save
        flash[:notice] = t('message.sent_successfully')
        format.html { redirect_to outbox_user_messages_path }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # DELETE /messages/1
  def destroy
    @message= Message.find_by_id(params[:id])
    
    respond_to do |format|
      if can_view(@message)
        mark_message_for_destruction(@message)
        format.html { redirect_to current_mailbox }
      else
        headers["Status"] = "Forbidden"
        format.html {render :file => "public/403.html", :status => 403}
      end
    end
  end
  
  ### Non-CRUD Actions
  
  # GET /messages/inbox
  # GET /messages/inbox.xml
  # GET /messages/inbox.atom
  # Displays all new and read and undeleted messages in the User's inbox
  def inbox
    session[:mail_box] = "inbox"
    #@messages = rezm_user.inbox_messages.paginate(:page => params[:page])
    query = params[:query].to_s.strip
    @query = query.dup
    user = rezm_user
    page = params[:page] || 1
    search = Sunspot.new_search(Message)
    search.build do
      fulltext query if query.present?
      with(:receiver_id).equal_to user.id
      with(:receiver_deleted).equal_to false
      with(:sender_deleted).equal_to false
      order_by(:created_at, :desc)
    end
    search.query.paginate page.to_i, Message.per_page
    begin
      @messages = search.execute!.results
    rescue RSolr::RequestError
      @messages = WillPaginate::Collection.create(1,1,0) do end
    end
    
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml  { render :xml    => @messages.to_xml }
      format.atom { render :action => "index", :layout => false }
    end
  end
  
  # GET /messages/outbox
  # Displays all messages sent by the user
  def outbox
    session[:mail_box] = "outbox"
    @messages = rezm_user.outbox_messages.paginate(:page => params[:page])
    
    respond_to do |format|
      format.html { render :action => "index" }
    end
  end
  
  # GET /messages/trashbin
  # Displays all messages deleted from the user's inbox
  def trashbin
    session[:mail_box] = "trashbin"
    @messages = rezm_user.trashbin_messages.paginate(:page => params[:page])

    respond_to do |format|
      format.html { render :action => "index" }
    end
  end
  
  # GET /messages/1/reply
  def reply
    @message = Message.find_by_id(params[:id])
    
    respond_to do |format|
      if can_view(@message)
        @message.recipient = @message.sender_name
        @message.subject = "Re: " + @message.subject 
        @message.body = "\n\n___________________________\n" + @message.sender_name + " wrote:\n\n" + @message.body
        format.html { render :action => "new" }
      else
        headers["Status"] = "Forbidden"
        format.html {render :file => "public/403.html", :status => 403}
      end
    end
  end
  
  # POST /messages/destroy_selected
  def destroy_selected
  
    respond_to do |format|
      if !params[:to_delete].nil?
        messages = params[:to_delete].map { |m| Message.find_by_id(m) } 
        messages.each do |message| 
          mark_message_for_destruction(message)
        end
        format.html { redirect_to current_mailbox }
      else
        format.html { redirect_to inbox_user_messages_path }
      end
    end
  end
  
  protected
          
  # Security check to make sure the requesting user is either the 
  # sender (for outbox display) or the receiver (for inbox or trash_bin display)
  def can_view(message)
    true if !message.nil? and (rezm_user.id == message.sender_id or rezm_user.id == message.receiver_id)
  end
  
  def current_mailbox
    case session[:mail_box]
    when "inbox"
      inbox_user_messages_path
    when "outbox"
      outbox_user_messages_path
    when "trashbin"
      trashbin_user_messages_path
    else
      inbox_user_messages_path
    end
  end
  
  # Performs a "soft" delete of a message then check if it can do a destroy on the message
  # * Marks Inbox messages as "receiver deleted" essentially moving the message to the Trash Bin
  # * Marks Outbox messages as "sender_deleted" and "purged" removing the message from [:inbox_messages, :outbox_messages, :trashbin_messages]
  # * Marks Trash Bin messages as "receiver purged"
  # * Checks to see if both the sender and reciever have purged the message.  If so, the message record is destroyed
  #
  # Returns to the updated view of the current "mailbox"
  def mark_message_for_destruction(message)
    if can_view(message)
      
      # "inbox"
      if rezm_user.id == message.receiver_id and !message.receiver_deleted
        message.receiver_deleted = true             
            
      # "outbox"
      elsif rezm_user.id == message.sender_id
        message.sender_deleted = true
        message.sender_purged = true
            
      # "trash_bin"
      elsif rezm_user.id == message.receiver_id and message.receiver_deleted
        message.receiver_purged = true
      end
      
      message.save(false) 
      message.purge
    end
  end

  def set_rezm_user
    @rezm_user = rezm_user
  end

end
