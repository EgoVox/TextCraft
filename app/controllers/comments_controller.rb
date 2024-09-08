class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story

  def create
    @comment = @story.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to @story, notice: 'Le commentaire a été ajouté avec succès.'
    else
      redirect_to @story, alert: 'Impossible de créer le commentaire'
    end
  end

  def destroy
    @comment = @story.comments.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      redirect_to @story, notice: 'Le commentaire a été supprimé avec succès.'
    else
      redirect_to @story, alert: 'Vous ne pouvez pas supprimer ce commentaire.'
    end
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:story_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
