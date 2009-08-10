class QuestionsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user_if_nil, :except => [:edit]

  # GET /questions
  # GET /questions.xml
  def index
    store_location
    session[:params] = {} unless session[:params]
    session[:params][:question] = params

    @count = {}

    search = Sunspot.new_search(Question)
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.query.keywords = query
    end

    if @user
      if logged_in?
        search.query.add_restriction(:login, :equal_to, @user.login) unless current_user.has_role?('Librarian')
      end
    end
    search.query.order_by(:updated_at, :desc)
    page = params[:page] || 1
    search.query.paginate(page.to_i, Question.per_page)
    begin
      @questions = search.execute!.results
    rescue RSolr::RequestError
      @questions = WillPaginate::Collection.create(1,1,0) do end
    end
    @count[:query_result] = @questions.total_entries

    if query
      search_porta_crd(query)
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @questions.to_xml }
      format.rss  { render :layout => false }
      format.atom
      format.js {
        render :update do |page|
          page.replace_html 'result_index', :partial => 'list' if params[:page]
          page.replace_html 'submenu', :partial => 'crd' if params[:crd_page]
        end
      }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    if @user
      @question = @user.questions.find(params[:id])
    else
      @question = Question.find(params[:id])
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
    @question = current_user.questions.new
  end

  # GET /questions/1;edit
  def edit
    if @user
      @question = @user.questions.find(params[:id])
    else
      @question = Question.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = current_user.questions.new(params[:question])

    respond_to do |format|
      if @question.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.question'))
        format.html { redirect_to user_question_url(@question.user.login, @question) }
        format.xml  { render :xml => @question, :status => :created, :location => user_question_url(@question.user.login, @question) }
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
    if @user
      @question = @user.questions.find(params[:id])
    else
      @question = Question.find(params[:id])
    end
    @question.destroy

    respond_to do |format|
      format.html { redirect_to user_questions_url(@question.user.login) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private
  def search_porta_crd(query)
    @refkyo_count = 0
    crd_startrecord = (params[:crd_page].to_i - 1) * Question.crd_per_page + 1
    if crd_startrecord < 1
      crd_startrecord = 1
    end
    if params[:crd_page]
      crd_page = params[:crd_page].to_i
    else
      crd_page = 1
    end
    refkyo_resource = Question.search_porta(query, {:dpid => 'refkyo', :item => 'any', :raw => false, :startrecord => crd_startrecord, :per_page => Question.crd_per_page})
    @resources = refkyo_resource.items
    @refkyo_count = refkyo_resource.channel.totalResults.to_i
    if @refkyo_count > 1000
      crd_total_count = 1000
    else
      crd_total_count = @refkyo_count
    end
    @crd_results = WillPaginate::Collection.create(crd_page, Question.crd_per_page, crd_total_count) do |pager| pager.replace(@resources) end
  end

end
