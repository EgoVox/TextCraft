require 'net/http'
require 'uri'
require 'json'
require 'concurrent'  # Threads en // sur language_tool_api

class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story
  before_action :set_chapter_by_position, only: [:show, :destroy]
  before_action :set_chapter_by_id, only: [:edit, :update]

  MAX_TEXT_LENGTH = 20000  # Limite de caractères pour l'API LanguageTool

  def show
    Read.mark_as_read(current_user, @story, @chapter) if user_signed_in?
  end

  def new
    @chapter = @story.chapters.build
  end

  def create
    @chapter = @story.chapters.build(chapter_params)

    # Analyse du chapitre
    analysis_result = analyze_text(@chapter.content)
    @score = analysis_result[:score]
    @message = analysis_result[:message]

    if analysis_result[:passed]
      if @chapter.save
        flash[:notice] = "Chapitre créé avec succès. Qualité du texte : #{analysis_result[:score]}%. Forces et axes d'amélioration : #{analysis_result}".html_safe
        redirect_to story_chapter_path(@story, @chapter.position)
      else
        flash.now[:alert] = 'Erreur lors de la création du chapitre.'
        render :new
      end
    else
      flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{analysis_result[:score]}%. Axes d'amélioration : #{analysis_result}".html_safe
      render :new
    end
  end

  def edit
  end

  def update
    if @chapter.update(chapter_params)
      analysis_result = analyze_text(@chapter.content)
      @score = analysis_result[:score]
      @message = analysis_result[:message]

      if analysis_result[:passed]
        flash[:notice] = "Chapitre mis à jour avec succès. Qualité du texte : #{@score}%. #{@message}"
        redirect_to story_chapter_path(@story, @chapter.position)
      else
        flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{@score}%. #{@message}"
        # On ne redirige pas si l'analyse échoue, on reste sur la page d'édition
        render :edit
      end
    else
      # Si la mise à jour échoue pour d'autres raisons (validations Rails, etc.)
      render :edit
    end
  end

  def destroy
    @chapter.destroy
    redirect_to story_path(@story), notice: 'Chapitre supprimé avec succès.'
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:story_id])
  end

  def set_chapter_by_position
    @chapter = @story.chapters.find_by!(position: params[:id])
  end

  def set_chapter_by_id
    @chapter = @story.chapters.find(params[:id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :content)
  end

def analyze_text(content)
  analysis_result = analyze_text_for_feedback(content)

  score = analysis_result[:score]
  feedback = analysis_result[:feedback]

  # Afficher le score final et le feedback final
  if score >= 75
    return { score: score, passed: true, message: "Le texte est validé avec un score de #{score}%. Voici les raisons : #{feedback.join(', ')}" }
  else
    return { score: score, passed: false, message: "Le texte a échoué à l'analyse avec un score de #{score}%. Voici les raisons : #{feedback.join(', ')}" }
  end
end

# Analyse avec feedback et calcul du score
def analyze_text_for_feedback(content)
  feedback = []
  score = 100

  # Critère : usage du langage vulgaire
  if contains_vulgarity?(content)
    feedback << "Le texte contient un langage vulgaire ou inapproprié."
    score -= 50  # Critère éliminatoire
  end

  # Critère : format de dialogue incorrect
  if incorrect_dialogue_format?(content)
    feedback << "Le texte utilise un format incorrect pour les dialogues (ex: 'Moi: ...')."
    score -= 50  # Critère éliminatoire
  end

  # Critère : usage excessif des parenthèses
  if excessive_parentheses?(content)
    feedback << "Le texte contient des parenthèses pour décrire des actions ou des dialogues."
    score -= 50  # Critère éliminatoire
  end

  # Vérification des répétitions excessives
    if content.size < 500 && excessive_repetition?(content)
      feedback << "Le texte contient trop de répétitions de mots pour sa petite taille."
      score -= 20
    end

    if content.size > 500 && excessive_repetition?(content)
      feedback << "Le texte contient quelquesrépétitions de mots."
      score -= 10
    end

  # Vérification de la complexité du vocabulaire
  is_simplistic, long_word_ratio = low_text_complexity?(content)

  if is_simplistic
    feedback << "Le vocabulaire est trop simpliste (#{(long_word_ratio * 100).round(2)}% de mots longs)."
    score -= 20
  end

  text_size = content.split.size

  # Vérification des fautes d'orthographe et de grammaire
  spelling_errors = check_spelling(content)
  grammar_errors = check_grammar(content)
  conjugation_errors = check_conjugation(content)

  if conjugation_errors > 0
    feedback << "Le texte contient #{conjugation_errors} fautes de conjugaison."
    score -= conjugation_errors * 0.5
  end

  #pondération des fautes en fonction de la taille du texte
  if text_size > 500
    if spelling_errors > 0
      feedback << "Le texte contient #{spelling_errors} fautes d'orthographe."
      score -= spelling_errors * 0.125  # Pénalité de -0.25 par faute d'orthographe
    end

    if grammar_errors > 0
      feedback << "Le texte contient #{grammar_errors} fautes de grammaire."
      score -= grammar_errors * 0.25  # Pénalité de -0.5 par faute de grammaire/conjugaison
    end
  elsif text_size <= 500
    if spelling_errors > 0
      feedback << "Le texte contient #{spelling_errors} fautes d'orthographe."
      score -= spelling_errors * 0.25  # Pénalité de -0.5 par faute d'orthographe
    end

    if grammar_errors > 0
      feedback << "Le texte contient #{grammar_errors} fautes de grammaire."
      score -= grammar_errors * 0.5  # Pénalité de -1 par faute de grammaire/conjugaison
    end
  end

  feedback << "Le texte respecte tous les critères de lisibilité." if feedback.empty?

  # Ajout du feedback GPT selon le score
  gpt_feedback = call_gpt_for_feedback(content, score)
  feedback += gpt_feedback[:feedback]

  # Ajustement du score avec vérification
  gpt_score_adjustment = gpt_feedback[:score_adjustment] || 0
  score += gpt_score_adjustment

  # S'assurer que le score ne dépasse pas 100 ni ne descend en dessous de 0
  score = [[score, 0].max, 100].min
  { score: score, feedback: feedback }
end

def call_gpt_for_feedback(content, score)
  client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

  if score < 70
    prompt = "Ce texte a obtenu un score de #{score}/100 en lisibilité. Le texte n'est pas adapté pour la publication dans sa forme actuelle. Donne 3 critiques claires et directes sur les principales faiblesses du texte, en indiquant précisément ce qui ne va pas et ce qui doit être changé."
  else
    prompt = "Ce texte a obtenu un score de #{score}/100. Bien qu'il soit de bonne qualité et publiable, il peut encore être amélioré. Identifie 2 aspects forts du texte et donne une critique précise sur ce qui doit être changé pour en faire un récit exceptionnel."
  end

  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "Tu es un assistant de correction de texte et d'amélioration de récits." },
        { role: "user", content: prompt }
      ],
      max_tokens: 500
    }
  )

  gpt_response = response['choices'].first['message']['content']
  feedback = gpt_response.split("\n").reject(&:empty?)

  # Optionnel : ajuster le score basé sur les retours de GPT, ici juste pour l'exemple
  score_adjustment = feedback.include?("excellent") ? 5 : 0

  { feedback: feedback, score_adjustment: score_adjustment }
end

# Vérifie si le vocabulaire est trop simpliste
def low_text_complexity?(content)
  words = content.split
  long_words = words.select { |word| word.length > 6 }
  long_word_ratio = long_words.size.to_f / words.size

  # Seuil de complexité à 10% de mots longs
  [long_word_ratio < 0.10, long_word_ratio]
end

# Méthodes pour détecter les fautes, vulgarité, dialogues incorrects, etc.
def check_spelling(content)
  response = call_language_tool_api(content)
  spelling_errors = response['matches'].select { |match| match['rule']['issueType'] == 'misspelling' }
  spelling_errors.size
end

def check_grammar(content)
  response = call_language_tool_api(content)
  grammar_errors = response['matches'].select { |match| match['rule']['issueType'] == 'grammar' }
  grammar_errors.size
end

def contains_vulgarity?(content)
  vulgar_words = ["pute", "putes", "merde", "connard", "salope", "enculé", "fils de pute"]
  vulgar_words.any? { |word| content.downcase.include?(word) }
end

def incorrect_dialogue_format?(content)
  content.scan(/(?:\w+:|(?:\(.*?\):))/).any?
end

def excessive_parentheses?(content)
  content.scan(/\(.*?\)/).any?
end

def excessive_repetition?(content)
  stop_words = %w[le la les de des un une et mais ou donc ni car que qui quoi dont où ainsi à dans par pour sur avec en je tu il elle nous vous ils elles on ne pas]
  words = content.downcase.scan(/\w+/).reject { |word| stop_words.include?(word) }
  word_frequency = words.each_with_object(Hash.new(0)) { |word, freq| freq[word] += 1 }
  repetition_threshold = [5, (words.size / 500)].max
  repeated_words = word_frequency.select { |_, count| count > repetition_threshold }
  repeated_words.any?
end

  def check_conjugation(content)
    response = call_language_tool_api(content)
    conjugation_errors = response['matches'].select { |match| match['rule']['id'].include?('TENSE_AGREEMENT') }
    conjugation_errors.size
  end

  def check_spelling(content)
    response = call_language_tool_api(content)
    spelling_errors = response['matches'].select { |match| match['rule']['issueType'] == 'misspelling' }
    spelling_errors.size
  end

  def check_grammar(content)
    response = call_language_tool_api(content)
    grammar_errors = response['matches'].select { |match| match['rule']['issueType'] == 'grammar' }
    grammar_errors.size
  end

  # Fonction pour appeler l'API de LanguageTool en tenant compte de la limite de 20 000 caractères
  def call_language_tool_api(content)
    responses = Concurrent::Array.new  # Utilise un tableau thread-safe
    content_chunks = content.scan(/.{1,#{MAX_TEXT_LENGTH}}/m)

    threads = content_chunks.map do |chunk|
      Thread.new do
        uri = URI.parse("https://api.languagetool.org/v2/check")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data("text" => chunk, "language" => "fr")

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        responses << JSON.parse(response.body)
      end
    end

    threads.each(&:join)

    merged_response = { 'matches' => [] }
    responses.each do |response|
      merged_response['matches'] += response['matches']
    end

    merged_response
  end
end
