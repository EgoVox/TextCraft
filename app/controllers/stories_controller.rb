class StoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
    if user_signed_in?
      @read_stories = Story.joins(:reads)
                          .where(reads: { user_id: current_user.id })
                          .where.not(user_id: current_user.id)  # Exclure les histoires créées par l'utilisateur
                          .group('stories.id')
                          .order('MAX(reads.created_at) DESC')
                          .limit(10)

      # Récupérer uniquement le dernier chapitre lu pour chaque histoire
      @last_read_chapters = @read_stories.map do |story|
        story.last_read_chapter_for_user(current_user)
      end

      # Récupérer les histoires créées par l'utilisateur
      @my_stories = current_user.stories.order(created_at: :desc)

      # Afficher les 8 dernières histoires mises à jour (toutes les histoires)
      @stories = Story.joins(:chapters).distinct.order(updated_at: :desc).limit(8)
    # else
    #   # Si l'utilisateur n'est pas connecté : collection vide
    #   @read_stories = []
    #   # Afficher les 5 dernières histoires mises à jour pour les utilisateurs non connectés
    #   @stories = Story.order(updated_at: :desc).limit(5)
    end
  end

  def show
    # @story = Story.find_by(slug: params[:id])  # Recherche l'histoire par son slug
  end

  def new
    @story = current_user.stories.build
  end

  def create
    @story = current_user.stories.build(story_params)
    if @story.save
      redirect_to @story, notice: 'L\'histoire a été créée avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @story.update(story_params)
      redirect_to @story, notice: 'L\'histoire a été mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @story.destroy
    redirect_to stories_url, notice: 'L\'histoire a été supprimée avec succès.'
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:id])
  end

  def story_params
    params.require(:story).permit(:title, :description, :category_id, :cover_image_url)
  end
end
