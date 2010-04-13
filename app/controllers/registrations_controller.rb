class RegistrationsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_in
  def new
    build_resource
    render_with_scope :new
  end

  # POST /resource/sign_up
  def create
    build_resource
    resource.operator = current_user
    if resource.patron_id
      resource.patron = Patron.first(:conditions => {:id => resource.patron_id})
    end
    if resource.operator
      password = Devise.friendly_token
      resource.password = password
    end

    if resource.save
      resource.roles << Role.first(:conditions => {:name => 'User'})
      if resource.operator
        flash[:temporary_password] = password
        flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
        resource.confirm!
        redirect_to user_url(resource.username)
      else
        flash[:"#{resource_name}_signed_up"] = true
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      end
    else
      render_with_scope :new
    end
  end

  # GET /resource/edit
  def edit
    render_with_scope :edit
  end

  # PUT /resource
  def update
    if self.resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to after_sign_in_path_for(self.resource)
    else
      render_with_scope :edit
    end
  end

  # DELETE /resource
  def destroy
    self.resource.destroy
    set_flash_message :notice, :destroyed
    sign_out_and_redirect(self.resource)
  end

  protected

    # Authenticates the current scope and dup the resource
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!")
      self.resource = send(:"current_#{resource_name}").dup
    end
end
