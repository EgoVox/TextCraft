class ApplicationController < ActionController::Base
  layout :set_layout
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username, :city, :gender, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username, :city, :gender, :bio])
  end

  private

  def set_layout
    if devise_controller?
      "application"
    else
      "application" # ou un autre layout si nécessaire pour d'autres parties du site
    end
  end
end
