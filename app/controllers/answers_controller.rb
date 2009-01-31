class AnswersController < ApplicationController
  before_filter :login_required
  before_filter :get_user_if_nil, :only => [:index]
  before_filter :get_user, :except => [:index]
  before_filter :get_question, :except => [:destroy] # 上書き注意
  before_filter :authorized_content, :except => [:index, :show]
  #before_filter :public_content, :only => [:index, :show]

  # GET /answers
  # GET /answers.xml
  def index
    @count = {}
    if @question and @user
      @answers = @question.answers.paginate(:all, :page => params[:page], :per_page => @per_page, :conditions => ['answers.user_id = ?', @user.id], :order => ['answers.id'])
    elsif @user
      @answers = @user.answers.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['answers.id'])
    else
      access_denied
      return
    end
    @count[:query_result] = @answers.size

    @startrecord = (params[:page].to_i - 1) * Answer.per_page + 1
    if @startrecord < 1
      @startrecord = 1
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @answers.to_xml }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /answers/1
  # GET /answers/1.xml
  def show
    @answer = @user.answers.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @answer.to_xml }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /answers/new
  def new
    if @question
      @answer = @user.answers.new
    else
      flash[:notice] = ('Specify question id.')
      redirect_to user_questions_url(@user.login)
    end
  end

  # GET /answers/1;edit
  def edit
    @answer = @user.answers.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /answers
  # POST /answers.xml
  def create
    @answer = @user.answers.new(params[:answer])

    respond_to do |format|
      if @answer.save
        flash[:notice] = ('Answer was successfully created.')
        format.html { redirect_to user_question_answer_url(@answer.user.login, @answer.question, @answer) }
        format.xml  { head :created, :location => user_question_answer_url(@answer.user.login, @answer.question, @answer) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @answer.errors.to_xml }
      end
    end
  end

  # PUT /answers/1
  # PUT /answers/1.xml
  def update
    @answer = @user.answers.find(params[:id])

    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        flash[:notice] = ('Answer was successfully updated.')
        format.html { redirect_to user_question_answer_url(@answer.user.login, @answer.question, @answer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /answers/1
  # DELETE /answers/1.xml
  def destroy
    @answer = @user.answers.find(params[:id])
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to user_question_answers_url(@answer.user.login, @answer.question) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private
  def get_question
    @question = Question.find(params[:question_id]) rescue nil
    #access_denied unless @question
  end
end
