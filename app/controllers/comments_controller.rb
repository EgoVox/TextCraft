class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      if @commentable.is_a?(Chapter)
        redirect_to story_chapter_path(@commentable.story, @commentable.position), notice: 'Le commentaire a été ajouté avec succès.'
      else
        redirect_to @commentable, notice: 'Le commentaire a été ajouté avec succès.'
      end
    else
      if @commentable.is_a?(Chapter)
        redirect_to story_chapter_path(@commentable.story, @commentable.position), alert: 'Impossible de créer le commentaire.'
      else
        redirect_to @commentable, alert: 'Impossible de créer le commentaire.'
      end
    end
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      if @commentable.is_a?(Chapter)
        redirect_to story_chapter_path(@commentable.story, @commentable.position), notice: 'Le commentaire a été supprimé avec succès.'
      else
        redirect_to @commentable, notice: 'Le commentaire a été supprimé avec succès.'
      end
    else
      redirect_to @commentable, alert: 'Vous ne pouvez pas supprimer ce commentaire.'
    end
  end

  def comments_count
    comments.size
  end

  private

  def set_commentable
    if params[:story_id]
      @commentable = Story.find_by(slug: params[:story_id])
    elsif params[:chapter_id]
      @commentable = Chapter.find(params[:chapter_id])
    end
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
