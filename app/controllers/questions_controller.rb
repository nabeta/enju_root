class QuestionsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_user_if_nil, :only => [:index, :show]
  before_filter :get_user, :except => [:index, :show]
  before_filter :authorized_content, :except => [:index, :show]

  # GET /questions
  # GET /questions.xml
  def index
    store_location
    session[:params] = {} unless session[:params]
    session[:params][:question] = params

    @count = {}
    @refkyo_count = 0
    @startrecord = (params[:page].to_i - 1) * Question.per_page + 1
    if @startrecord < 1
      @startrecord = 1
    end

    query = params[:query].to_s.strip
    unless query.blank?
      @query = query

      if @user
        if logged_in?
          query = "#{query} login: #{@user.login}" unless current_user.has_role?('Librarian')
        end
      end

      @questions = Question.paginate_by_solr(query, :page => params[:page], :per_page => @per_page, :order => 'updated_at desc').compact
      refkyo_resources = Question.refkyo_search(params[:query], @startrecord)
      @resources = refkyo_resources[:resources]
      if params[:page]
        @page = params[:page].to_i
      else
        @page = 1
      end
      @refkyo_count = refkyo_resources[:total_count]
    else
      if @user
        @questions = @user.questions.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['questions.updated_at DESC'])
      else
        @questions = Question.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['questions.updated_at DESC'])
      end
    end

    @count[:query_result] = @questions.size

    @startrecord = (params[:page].to_i - 1) * Question.per_page + 1
    @startrecord = 1 if @startrecord < 1

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @questions.to_xml }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    if @user
      @question = @user.questions.find(params[:id])
    else
      access_denied
      return
    end

    if @question.private_question?
      if logged_in?
        unless @question.user == current_user or current_user.has_role?('Librarian')
          access_denied
          return
        end
      end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @question.to_xml }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /questions/new
  def new
    @question = @user.questions.new
  end

  # GET /questions/1;edit
  def edit
    @question = @user.questions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = @user.questions.new(params[:question])

    respond_to do |format|
      if @question.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.question'))
        format.html { redirect_to user_question_url(@question.user.login, @question) }
        format.xml  { head :created, :location => user_question_url(@question.user.login, @question) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors.to_xml }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = @user.questions.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.question'))
        format.html { redirect_to user_question_url(@question.user.login, @question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = @user.questions.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to user_questions_url(@question.user.login) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

end
