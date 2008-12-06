class ExpressionFormsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]

  # GET /expression_forms
  # GET /expression_forms.xml
  def index
    @expression_forms = ExpressionForm.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @expression_forms.to_xml }
    end
  end

  # GET /expression_forms/1
  # GET /expression_forms/1.xml
  def show
    @expression_form = ExpressionForm.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @expression_form.to_xml }
    end
  end

  # GET /expression_forms/new
  def new
    @expression_form = ExpressionForm.new
  end

  # GET /expression_forms/1;edit
  def edit
    @expression_form = ExpressionForm.find(params[:id])
  end

  # POST /expression_forms
  # POST /expression_forms.xml
  def create
    @expression_form = ExpressionForm.new(params[:expression_form])

    respond_to do |format|
      if @expression_form.save
        flash[:notice] = ('ExpressionForm was successfully created.')
        format.html { redirect_to expression_form_url(@expression_form) }
        format.xml  { head :created, :location => expression_form_url(@expression_form) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_form.errors.to_xml }
      end
    end
  end

  # PUT /expression_forms/1
  # PUT /expression_forms/1.xml
  def update
    @expression_form = ExpressionForm.find(params[:id])

    if @expression_form and params[:position]
      @expression_form.insert_at(params[:position])
      redirect_to expression_forms_url
      return
    end

    respond_to do |format|
      if @expression_form.update_attributes(params[:expression_form])
        flash[:notice] = ('ExpressionForm was successfully updated.')
        format.html { redirect_to expression_form_url(@expression_form) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_form.errors.to_xml }
      end
    end
  end

  # DELETE /expression_forms/1
  # DELETE /expression_forms/1.xml
  def destroy
    @expression_form = ExpressionForm.find(params[:id])
    @expression_form.destroy

    respond_to do |format|
      format.html { redirect_to expression_forms_url }
      format.xml  { head :ok }
    end
  end
end
