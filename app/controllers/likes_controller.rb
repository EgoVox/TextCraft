class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story

  def create
    @like = @story.likes.build(user: current_user)
    if @like.save
      respond_to do |format|
        format.js # like.js.erb
        format.html { redirect_to @story, notice: 'Vous aimez cette histoire' }
      end
    else
      respond_to do |format|
        format.js { render 'error.js.erb' }
        format.html { redirect_to @story, alert: 'Un problème est survenu lors de la sauvegarde de votre like' }
      end
    end
  end

  def destroy
    @like = @story.likes.find_by(user: current_user)
    if @like
      @like.destroy
      respond_to do |format|
        format.js # unlike.js.erb
        format.html { redirect_to @story, notice: 'Vous n\'aimez plus cette histoire' }
      end
    else
      respond_to do |format|
        format.js { render 'error.js.erb' }
        format.html { redirect_to @story, alert: 'Un problème est survenu lors de la suppression de votre like' }
      end
    end
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:story_id])
  end
end
