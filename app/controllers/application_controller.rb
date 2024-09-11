class ApplicationController < ActionController::Base
  layout :set_layout

  private

  def set_layout
    if devise_controller?
      "application"
    else
      "application" # ou un autre layout si nécessaire pour d'autres parties du site
    end
  end
end
