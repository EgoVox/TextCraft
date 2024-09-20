class ApplicationController < ActionController::Base
  layout :set_layout
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_color

  def set_user_color
    @user_color = current_user&.primary_color || "#ff6f61"
    puts "Couleur utilisateur (#{current_user&.username}): #{@user_color}" if current_user
  end

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
