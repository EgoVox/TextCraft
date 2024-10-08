class StoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_story, only: [:show, :edit, :update, :destroy, :analyze]

  def index
    if params[:query].present?
      @stories = Story.search_by_title_description_and_tags(params[:query])
    else
      @stories = Story.joins(:chapters).distinct.order(updated_at: :desc).limit(8)
    end

    if user_signed_in?
      @read_stories = Story.joins(:reads)
                           .where(reads: { user_id: current_user.id })
                           .where.not(user_id: current_user.id)
                           .group('stories.id')
                           .order('MAX(reads.created_at) DESC')
                           .limit(8)

      @most_commented_stories = Story.joins(:comments)
                                     .group('stories.id')
                                     .order('COUNT(comments.id) DESC')
                                     .limit(8)

      @top_liked_stories = Story.left_joins(:likes)
                                .group(:id)
                                .order('COUNT(likes.id) DESC')
                                .limit(10)

      @my_stories = current_user.stories.order(created_at: :desc)

      @last_read_chapters = @read_stories.map do |story|
        story.last_read_chapter_for_user(current_user)
      end
    else
      @read_stories = []
      @most_commented_stories = []
      @top_liked_stories = []
      @my_stories = []
      @last_read_chapters = []
    end
  end

  def show
  end

  def new
    @story = current_user.stories.build
  end

  def create
    @story = current_user.stories.build(story_params)

    if @story.save
      redirect_to @story, notice: "L'histoire a été créée avec succès."
    else
      render :new
    end
  end

  def edit
    @suggested_tags = @story.suggested_tags || [] # Assure qu'il s'agit d'un tableau vide si nil
  end

  def update
    @story.assign_attributes(story_params)

    # Gérer les tags prédéfinis (via leur ID)
    if params[:story][:tag_ids].present?
      @story.tag_ids = params[:story][:tag_ids].reject(&:blank?)
    end

    # Gérer les tags suggérés (stockés en tant que tableau de chaînes dans suggested_tags)
    if params[:story][:suggested_tags].present?
      # Ici, on ne modifie pas l'association tags, mais on stocke les tags suggérés en tant que chaînes de caractères
      @story.suggested_tags = params[:story][:suggested_tags].reject(&:blank?)
    end

    if @story.save
      redirect_to @story, notice: "L'histoire a été mise à jour avec succès."
    else
      Rails.logger.debug "Erreurs : #{@story.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @story.destroy
    redirect_to stories_url, notice: "L'histoire a été supprimée avec succès."
  end

  def search
    if params[:query].present?
      @stories = Story.search_by_title_description_and_tags(params[:query])
    else
      @stories = Story.all
    end
  end

  def analyze
    @suggested_tags = analyze_story_summary(@story.description)
    puts "#{@story.description}"

    respond_to do |format|
      format.js # Rend le fichier analyze.js.erb
      format.json { render json: { tags: @suggested_tags } } # Optionnel pour le debug
    end
  end

  private

  def analyze_story_summary(description)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    prompt = "Donne 10 mots-clés pertinents que t'inspire ce résumé d'histoire et sépare-les par des virgules : #{description}"

    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
                { role: "system", content: "Tu es un algorithme d'extraction de mots-clés pour un site qui publie des manuscrits." },
                { role: "user", content: prompt }
          ],
        }
      )
      response["choices"].first["message"]["content"].strip.split(", ").map(&:strip)
    rescue => e
      Rails.logger.error "Erreur lors de l'analyse : #{e.message}"
      []
    end
  end

  def set_story
    @story = Story.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Histoire introuvable."
    redirect_to stories_path
  end

  def story_params
    params.require(:story).permit(:title, :description, :category_id, :cover_image_url, tag_ids: [], suggested_tags: [])
  end
end
