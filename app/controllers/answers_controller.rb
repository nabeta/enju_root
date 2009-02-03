class AnswersController < ApplicationController
  before_filter :login_required
  before_filter :get_user_if_nil
  before_filter :get_question, :except => [:destroy]
  before_filter :authorized_content

  # GET /answers
  # GET /answers.xml
  def index
    @count = {}
    if @question
      @answers = @question.answers.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['answers.id'])
    else
      if @user
        @answers = @user.answers.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['answers.id'])
      else
        @answers = Answer.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['answers.id'])
      end
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
    if @question
      @answer = @question.answers.find(params[:id])
    else
      if @user
        @answer = @user.answers.find(params[:id])
      else
        @answer = Answer.find(params[:id])
      end
    end

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
      @answer = current_user.answers.new
      @answer.question = @question
    else
      flash[:notice] = ('Specify question id.')
      redirect_to user_questions_url(@user.login)
    end
  end

  # GET /answers/1;edit
  def edit
    if @question
      @answer = @question.answers.find(params[:id])
    else
      if @user
        @answer = @user.answers.find(params[:id])
      else
        @answer = Answer.find(params[:id])
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /answers
  # POST /answers.xml
  def create
    @answer = current_user.answers.new(params[:answer])

    respond_to do |format|
      if @answer.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.answer'))
        format.html { redirect_to user_question_answer_url(@answer.question.user.login, @answer.question, @answer) }
        format.xml  { head :created, :location => user_question_answer_url(@answer.question.user.login, @answer.question, @answer) }
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
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.answer'))
        format.html { redirect_to user_question_answer_url(@answer.question.user.login, @answer.question, @answer) }
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
    if @question
      @answer = @question.answers.find(params[:id])
    else
      if @user
        @answer = @user.answers.find(params[:id])
      else
        @answer = Answer.find(params[:id])
      end
    end
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to user_question_answers_url(@answer.question.user.login, @answer.question) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

end
