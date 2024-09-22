class StoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
    # Si une recherche est effectuée, utiliser la méthode de recherche
    if params[:query].present?
      @stories = Story.search_by_title_description_and_tags(params[:query])
    else
      # Par défaut, afficher les 8 dernières histoires mises à jour
      @stories = Story.joins(:chapters).distinct.order(updated_at: :desc).limit(8)
    end

    if user_signed_in?
      # Histoires lues par l'utilisateur
      @read_stories = Story.joins(:reads)
                           .where(reads: { user_id: current_user.id })
                           .where.not(user_id: current_user.id) # Exclure les histoires de l'utilisateur
                           .group('stories.id')
                           .order('MAX(reads.created_at) DESC')
                           .limit(8)

      # Histoires avec le plus de commentaires
      @most_commented_stories = Story.joins(:comments)
                                     .group('stories.id')
                                     .order('COUNT(comments.id) DESC')
                                     .limit(8)

      # Histoires avec le plus de likes
      @top_liked_stories = Story.left_joins(:likes)
                                .group(:id)
                                .order('COUNT(likes.id) DESC')
                                .limit(10)

      # Récupérer les histoires créées par l'utilisateur
      @my_stories = current_user.stories.order(created_at: :desc)

      # Récupérer le dernier chapitre lu pour chaque histoire
      @last_read_chapters = @read_stories.map do |story|
        story.last_read_chapter_for_user(current_user)
      end
    else
      # Si l'utilisateur n'est pas connecté, ces collections sont vides
      @read_stories = []
      @most_commented_stories = []
      @top_liked_stories = []
      @my_stories = []
      @last_read_chapters = []
    end
  end

  def show
    # L'histoire est déjà chargée par le before_action :set_story
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
    # L'histoire est déjà chargée par le before_action :set_story
  end

  def update
    # L'histoire est déjà chargée par le before_action :set_story

    # Assigner les nouveaux attributs à l'histoire existante
    @story.assign_attributes(story_params)

    if @story.save
      redirect_to @story, notice: 'L\'histoire a été mise à jour avec succès.'
    else
      Rails.logger.debug "Erreurs : #{@story.errors.full_messages.join(", ")}"
      render :edit
    end
  end

  def destroy
    @story.destroy
    redirect_to stories_url, notice: 'L\'histoire a été supprimée avec succès.'
  end

  def search
    if params[:query].present?
      @stories = Story.search_by_title_description_and_tags(params[:query])
    else
      @stories = Story.all
    end
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Histoire introuvable."
    redirect_to stories_path
  end

  def story_params
    params.require(:story).permit(:title, :description, :category_id, :cover_image_url, tag_ids: [])
  end
end
