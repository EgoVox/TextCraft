class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @stories = @user.stories
  end

  def update_color
    if current_user.update(user_params)
      Rails.logger.info "Couleur mise à jour pour #{current_user.username} : #{current_user.primary_color}"
      render json: { message: 'Couleur mise à jour avec succès' }, status: :ok
    else
      render json: { error: 'Erreur lors de la mise à jour de la couleur' }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:primary_color, :opposite_color)
  end
end
