class SessionsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  include Devise::Controllers::InternalHelpers
  ssl_allowed :new, :create, :destroy

  # GET /resource/sign_in
  def new
    unless resource_just_signed_up?
      Devise::FLASH_MESSAGES.each do |message|
        set_now_flash_message :alert, message if params.try(:[], message) == "true"
      end
    end

    build_resource
    render_with_scope :new
  end

  # POST /resource/sign_in
  def create
    if resource = authenticate(resource_name)
      set_flash_message :notice, :signed_in
      if session[:return_to]
        redirect_back_or_default
      else
        sign_in_and_redirect(resource_name, resource, true)
      end
    elsif [:custom, :redirect].include?(warden.result)
      throw :warden, :scope => resource_name
    else
      set_now_flash_message :alert, (warden.message || :invalid)
      clean_up_passwords(build_resource)
      render_with_scope :new
    end
  end

  # GET /resource/sign_out
  def destroy
    set_flash_message :notice, :signed_out if signed_in?(resource_name)
    sign_out_and_redirect(resource_name)
  end

  protected

    def resource_just_signed_up?
      flash[:"#{resource_name}_signed_up"]
    end

    def clean_up_passwords(object)
      object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
    end
end
