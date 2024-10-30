class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @stories = @user.stories

    if user_signed_in?

            @read_stories = Story.joins(:reads)
                           .where(reads: { user_id: current_user.id })
                           .where.not(user_id: current_user.id)
                           .group('stories.id')
                           .order('MAX(reads.created_at) DESC')
                           .limit(8)
        @last_read_chapters = @read_stories.map do |story|
        story.last_read_chapter_for_user(current_user)
      end
    else
      @read_stories = []
    end
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
