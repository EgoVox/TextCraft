class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story

  def create
    @like = @story.likes.build(user: current_user)
    if @like.save
      redirect_to @story, notice: 'Vous aimez cette histoire'
    else
      redirect_to @story, alert: 'Un problème est survenu lors de la sauvegarde de votre like'
    end
  end

  def destroy
    @like = @story.likes.find_by(user: current_user)
    if @like
      @like.destroy
      redirect_to @story, notice: 'Vous n\'aimez plus cette histoire'
    else
      redirect_to @story, alert: 'Un problème est survenu lors de la suppression de votre like'
    end
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:story_id])
  end
end
