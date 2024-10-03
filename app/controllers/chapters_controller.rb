require 'net/http'
require 'uri'
require 'json'
require 'concurrent'

class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story
  before_action :set_chapter_by_position, only: [:show, :destroy]
  before_action :set_chapter_by_id, only: [:edit, :update]

  MAX_TEXT_LENGTH = 20000

  def show
    Read.mark_as_read(current_user, @story, @chapter) if user_signed_in?
  end

  def new
    @chapter = @story.chapters.build
  end

  def create
    @chapter = @story.chapters.build(chapter_params)

    # Réinitialiser les informations d'analyse avant une nouvelle analyse
    reset_analysis_info

    # Effectuer l'analyse
    analysis_result = analyze_text_with_gpt(@chapter.content)

    # Mettre à jour le feedback et le score dans la base de données
    update_chapter_analysis_info(analysis_result)

    if analysis_result[:passed]
      if @chapter.save
        flash[:notice] = "Chapitre créé avec succès. Qualité du texte : #{@chapter.analysis_score}%."
        respond_to do |format|
          format.html { redirect_to story_chapter_path(@story, @chapter.position, show_modal: true) }
          format.turbo_stream { render_flash }
        end
      else
        flash.now[:alert] = 'Erreur lors de la création du chapitre.'
        respond_to do |format|
          format.html { render :new, locals: { show_modal: true } }
          format.turbo_stream { render_flash }
        end
      end
    else
      flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{@chapter.analysis_score}%. #{@chapter.analysis_feedback}"
      respond_to do |format|
        format.html { render :new, locals: { show_modal: true } }
        format.turbo_stream { render_flash }
      end
    end
  end

  def update
    @chapter = @story.chapters.build(chapter_params)

    # Réinitialiser les informations d'analyse avant une nouvelle analyse
    reset_analysis_info

    # Effectuer l'analyse
    analysis_result = analyze_text_with_gpt(@chapter.content)

    # Mettre à jour le feedback et le score dans la base de données
    update_chapter_analysis_info(analysis_result)

    if analysis_result[:passed]
      if @chapter.save
        flash[:notice] = "Chapitre mis à jour avec succès. Qualité du texte : #{@chapter.analysis_score}%."
        respond_to do |format|
          format.html { redirect_to story_chapter_path(@story, @chapter.position, show_modal: true) }
          format.turbo_stream { render_flash }
        end
      else
        flash.now[:alert] = 'Erreur lors de la mise à jour du chapitre.'
        respond_to do |format|
          format.html { render :edit, locals: { show_modal: true } }
          format.turbo_stream { render_flash }
        end
      end
    else
      flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{@chapter.analysis_score}%. #{@chapter.analysis_feedback}"
      respond_to do |format|
        format.html { render :edit, locals: { show_modal: true } }
        format.turbo_stream { render_flash }
      end
    end
  end

  def destroy
    @chapter.destroy
    flash[:notice] = 'Chapitre supprimé avec succès.'
    respond_to do |format|
      format.html { redirect_to story_path(@story) }
      format.turbo_stream { render_flash }
    end
  end

  private

  def set_story
    @story = Story.find_by!(slug: params[:story_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Histoire introuvable."
    redirect_to stories_path
  end

  def set_chapter_by_position
    @chapter = @story.chapters.find_by!(position: params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Chapitre introuvable pour la position donnée."
    redirect_to story_path(@story)
  end

  def set_chapter_by_id
    @chapter = @story.chapters.find(params[:id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :content)
  end

  def reset_analysis_info
    @chapter.analysis_score = nil
    @chapter.analysis_feedback = nil
  end

  def update_chapter_analysis_info(analysis_result)
    @chapter.analysis_feedback = feedback_message(analysis_result)
    @chapter.analysis_score = analysis_result[:final_score]
    session[:feedback] = @chapter.analysis_feedback
    session[:analysis_score] = @chapter.analysis_score
  end

private

def analyze_text_with_gpt(content)
  plain_text_content = content.to_s

  # 1. Analyse de la lisibilité, vulgarité, répétitions, etc.
  readability_result = analyze_readability_with_gpt(plain_text_content)

  # 2. Évaluation de la qualité en tant que chapitre de livre
  chapter_quality_result = evaluate_chapter_quality_with_gpt(plain_text_content)

  # 3. Feedback détaillé et concis de GPT
  # detailed_feedback_result = call_gpt_for_detailed_feedback(plain_text_content, chapter_quality_result[:score])

  # 4. Calcul de la nouvelle moyenne avec le score de lisibilité, qualité, et feedback
  final_score = (readability_result[:score] + chapter_quality_result[:score]) / 2.0

  {
    final_score: final_score.round(2),
    readability_feedback: readability_result[:feedback],
    chapter_quality_feedback: chapter_quality_result[:feedback],
    # detailed_feedback: detailed_feedback_result[:feedback],
    passed: final_score >= 70
  }
end

def analyze_readability_with_gpt(content)
  client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  prompt = "Analyse ce texte en tant que critique littéraire en examinant les éléments suivants :
              - **Respect des conventions littéraires** (note sur 5),
              - **Structre du texte** (note sur 5),
              - **Vocabulaire** (note sur 5),
              - **Originalité** (note sur 5),
              - **Orthographe** (note sur 5),
              - **Grammaire** (note sur 5),
              - **Conjugaison** (note sur 5),
              - **Complexité** (note sur 5),
              - **Absence de vulgarité** (5 si aucune, 0 si trop présente),
              - **Fluidité** (note sur 5).

            N'indique pas le calcul. Multipilie le total par 2 et ne donne que la note sur 100. Justifie ta note en deux phrases.
            Voici le texte : #{content}"

  begin
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "Tu es un expert en linguistique et littérature. Évalue les textes de manière précise et concise en fonction des conventions littéraires classiques." },
          { role: "user", content: prompt }
        ],
        max_tokens: 300  # Limiter le nombre de tokens pour forcer la concision
      }
    )

      feedback = response['choices'].first['message']['content']
      score = extract_score_from_feedback(feedback)

      # Supprimer toute analyse détaillée si le texte est rejeté
      clean_feedback = feedback.split(', orthographe')[0] # Limiter le feedback jusqu'à la note d'orthographe
      puts "Score de lisibilité reçu de GPT : #{score}"
      { score: score, feedback: clean_feedback }

  rescue StandardError => e
    Rails.logger.error "Erreur OpenAI : #{e.message}"
    { score: 0, feedback: "Erreur lors de l'évaluation de la lisibilité." }
  end
end


  def evaluate_chapter_quality_with_gpt(content)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    prompt = "Donne obligatoirement une note globale sur 100 en évaluant ce texte en tant que chapitre d'un livre en considérant les aspects suivants :
              1. **Cohérence** dans le contexte d'un récit plus vaste (transition fluide, continuité).
              2. **Engagement du lecteur** (impact émotionnel, suspense, intérêt maintenu).
              3. **Clarté de la narration** (compréhension générale, fluidité des descriptions et dialogues).
              Ne donne qu'une analyse d'ensemble en 4 phrases.
              Voici le texte : #{content}"

    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "Tu es un expert en critique littéraire et spécialisé dans l'analyse de chapitres de livres." },
            { role: "user", content: prompt }
          ],
          max_tokens: 300  # Limiter le nombre de tokens pour un retour concis
        }
      )

        feedback = response['choices'].first['message']['content']
        score = extract_score_from_feedback(feedback)
        puts "Score de qualité de chapitre reçu de GPT : #{score}"
        { score: score, feedback: feedback }
    rescue StandardError => e
      Rails.logger.error "Erreur OpenAI : #{e.message}"
      { score: 0, feedback: "Erreur lors de l'évaluation de la qualité de chapitre." }
    end
  end

  # def call_gpt_for_detailed_feedback(content, score)
  #   puts "Appel à GPT pour un feedback détaillé et concis"
  #   client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

  #   prompt = if score < 70
  #               "Le texte suivant a obtenu un score de #{score}/100. Fournis 3 critiques courtes (1 phrase chacune) sur les principales faiblesses du texte. Utilise un langage direct et sans explications supplémentaires. Voici le texte : #{content}"
  #             else
  #               "Le texte suivant a obtenu un score de #{score}/100. Fournis 3 conseils précis (1 phrase chacun) pour améliorer le texte. Utilise un langage direct et sans explications supplémentaires. Voici le texte : #{content}"
  #             end

  #   begin
  #     response = client.chat(
  #       parameters: {
  #         model: "gpt-3.5-turbo",
  #         messages: [
  #           { role: "system", content: "Tu es un critique littéraire spécialisé dans l'évaluation de chapitres de romans. Sois concis." },
  #           { role: "user", content: prompt }
  #         ],
  #         max_tokens: 150  # Limiter le nombre de tokens pour un retour concis
  #       }
  #     )

  #     feedback = response['choices'].first['message']['content']
  #     score = extract_score_from_feedback(feedback)
  #     puts "Feedback détaillé reçu de GPT : #{feedback}"
  #     { feedback: feedback, score: score }
  #   rescue StandardError => e
  #     Rails.logger.error "Erreur OpenAI : #{e.message}"
  #     { feedback: "Erreur lors de l'évaluation avec GPT.", score: 0 }
  #   end
  # end

  def extract_score_from_feedback(feedback)
    if feedback.match(/(\d{1,2})\/100/)
      feedback.match(/(\d{1,2})\/100/)[1].to_i
    elsif feedback.match(/(\d{1,2})\/10/)
      feedback.match(/(\d{1,2})\/10/)[1].to_i * 10
    elsif feedback.match(/Note\s*[:\-]?\s*(\d{1,2})/)
      feedback.match(/Note\s*[:\-]?\s*(\d{1,2})/)[1].to_i
    else
      feedback.scan(/\d{1,2}/).map(&:to_i).max || 0
    end
  end

  def feedback_message(analysis_result)
    score = analysis_result[:final_score]
    lisibility_feedback = analysis_result[:readability_feedback]

    if score >= 70
      <<~FEEDBACK
        <i class="fa-solid fa-check" style="color: #00FF00;"></i>
        <strong>Félicitations, votre chapitre peut être publié en l'état.</strong><br>
        Votre score est de #{score} / 100.<br><br>
        <strong>Suggestions :</strong><br>
        - Lisibilité : #{lisibility_feedback}<br>
        - Qualité : #{analysis_result[:chapter_quality_feedback]}<br>
      FEEDBACK
    elsif score <= 50 && score > 0
      <<~FEEDBACK
        <i class="fa-solid fa-gear" style="color: #FF8000;"></i>
        <strong>Votre chapitre nécessite des améliorations avant d'être publié.</strong><br>
        Votre score est de #{score} / 100.<br><br>
        <strong>Pour viser plus haut :</strong><br>
        - Lisibilité : #{lisibility_feedback}<br>
        - Qualité : #{analysis_result[:chapter_quality_feedback]}<br>
      FEEDBACK
    else
      <<~FEEDBACK
        <i class="fa-solid fa-gear" style="color: #FF8000;"></i>
        <strong>Malheureusement, votre chapitre ne peut être publié en l'état.</strong><br>
        Votre score est de #{score} / 100, ce qui est trop bas.<br><br>
        <strong>Améliorations :</strong><br>
        - Lisibilité : #{lisibility_feedback}<br>
        - Qualité : #{analysis_result[:chapter_quality_feedback]}<br>
      FEEDBACK
    end
  end
end



















# old version with language_tool_api

# require 'net/http'
# require 'uri'
# require 'json'
# require 'concurrent'  # Threads en // sur language_tool_api

# class ChaptersController < ApplicationController
#   before_action :authenticate_user!
#   before_action :set_story
#   before_action :set_chapter_by_position, only: [:show, :destroy]
#   before_action :set_chapter_by_id, only: [:edit, :update]

#   MAX_TEXT_LENGTH = 20000  # Limite de caractères pour l'API LanguageTool

#   def show
#     Read.mark_as_read(current_user, @story, @chapter) if user_signed_in?
#   end

#   def new
#     @chapter = @story.chapters.build
#   end

#   def create
#     @chapter = @story.chapters.build(chapter_params)

#     # Réinitialiser les informations d'analyse avant une nouvelle analyse
#     @chapter.analysis_score = nil
#     @chapter.analysis_feedback = nil

#     # Effectuer l'analyse
#     analysis_result = analyze_text(@chapter.content)

#     # Mettre à jour le feedback et le score dans la base de données (même si le chapitre n'est pas sauvegardé)
#     @chapter.analysis_feedback = feedback_message(analysis_result)
#     @chapter.analysis_score = analysis_result[:final_score]

#     # Stocker le feedback dans la session pour afficher dans la modal
#     session[:feedback] = @chapter.analysis_feedback
#     session[:analysis_score] = @chapter.analysis_score

#     if analysis_result[:passed]
#       # Si le texte est validé, sauvegarder le chapitre avec l'analyse
#       if @chapter.save
#         flash[:notice] = "Chapitre créé avec succès. Qualité du texte : #{@chapter.analysis_score}%."
#         respond_to do |format|
#           format.html { redirect_to story_chapter_path(@story, @chapter.position, show_modal: true) }
#           format.turbo_stream { render_flash }
#         end
#       else
#         flash.now[:alert] = 'Erreur lors de la création du chapitre.'
#         respond_to do |format|
#           format.html { render :new, locals: { show_modal: true } }
#           format.turbo_stream { render_flash }
#         end
#       end
#     else
#       # Si le texte échoue à l'analyse, afficher la modal avec le feedback
#       flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{@chapter.analysis_score}%. #{@chapter.analysis_feedback}"
#       respond_to do |format|
#         format.html { render :new, locals: { show_modal: true } }
#         format.turbo_stream { render_flash }
#       end
#     end
#   end


#   def update
#     @chapter = @story.chapters.build(chapter_params)

#     # Réinitialiser les informations d'analyse avant une nouvelle analyse
#     @chapter.analysis_score = nil
#     @chapter.analysis_feedback = nil

#     # Effectuer l'analyse
#     analysis_result = analyze_text(@chapter.content)

#     # Mettre à jour le feedback et le score dans la base de données (même si le chapitre n'est pas sauvegardé)
#     @chapter.analysis_feedback = feedback_message(analysis_result)
#     @chapter.analysis_score = analysis_result[:final_score]

#     # Stocker le feedback dans la session pour afficher dans la modal
#     session[:feedback] = @chapter.analysis_feedback
#     session[:analysis_score] = @chapter.analysis_score

#     if analysis_result[:passed]
#       # Si le texte est validé, sauvegarder le chapitre avec l'analyse
#       if @chapter.save
#         flash[:notice] = "Chapitre créé avec succès. Qualité du texte : #{@chapter.analysis_score}%."
#         respond_to do |format|
#           format.html { redirect_to story_chapter_path(@story, @chapter.position, show_modal: true) }
#           format.turbo_stream { render_flash }
#         end
#       else
#         flash.now[:alert] = 'Erreur lors de la création du chapitre.'
#         respond_to do |format|
#           format.html { render :new, locals: { show_modal: true } }
#           format.turbo_stream { render_flash }
#         end
#       end
#     else
#       # Si le texte échoue à l'analyse, afficher la modal avec le feedback
#       flash.now[:alert] = "Le texte a échoué à l'analyse avec un score de #{@chapter.analysis_score}%. #{@chapter.analysis_feedback}"
#       respond_to do |format|
#         format.html { render :new, locals: { show_modal: true } }
#         format.turbo_stream { render_flash }
#       end
#     end
#   end



#   def destroy
#     @chapter.destroy
#     flash[:notice] = 'Chapitre supprimé avec succès.'
#     respond_to do |format|
#       format.html { redirect_to story_path(@story) }
#       format.turbo_stream { render_flash }
#     end
#   end

#   private

#   def set_story
#     @story = Story.find_by!(slug: params[:story_id])
#   rescue ActiveRecord::RecordNotFound
#     flash[:alert] = "Histoire introuvable."
#     redirect_to stories_path
#   end

#   def set_chapter_by_position
#     @chapter = @story.chapters.find_by!(position: params[:id])
#   rescue ActiveRecord::RecordNotFound
#     flash[:alert] = "Chapitre introuvable pour la position donnée."
#     redirect_to story_path(@story)
#   end

#   def set_chapter_by_id
#     @chapter = @story.chapters.find(params[:id])
#   end

#   def chapter_params
#     params.require(:chapter).permit(:title, :content)
#   end

#   def check_spelling(content)
#     response = call_language_tool_api(content)
#     spelling_errors = response['matches'].select { |match| match['rule']['issueType'] == 'misspelling' }
#     spelling_errors.size
#   end

#   def check_grammar(content)
#     response = call_language_tool_api(content)
#     grammar_errors = response['matches'].select { |match| match['rule']['issueType'] == 'grammar' }
#     grammar_errors.size
#   end

#   def check_conjugation(content)
#     response = call_language_tool_api(content)
#     conjugation_errors = response['matches'].select { |match| match['rule']['id'].include?('TENSE_AGREEMENT') }
#     conjugation_errors.size
#   end

#   def feedback_message(analysis_result)
#     # Utiliser une regex pour séparer les parties du feedback basé sur les numéros "1.", "2.", "3."
#     gpt_feedback = analysis_result[:interest_feedback].split(/(?=\d\.\s)/) rescue []

#     # Supprimer les numéros en double (1., 2., 3.) après le split
#     gpt_feedback = gpt_feedback.map { |feedback| feedback.sub(/^\d\.\s*/, '') }

#     # Ajout du rapport additionnel
#     additional_feedback = analysis_result[:readability_feedback].gsub("\n", "<br>") || "Aucun rapport additionnel disponible."

#     if analysis_result[:passed]
#       <<~FEEDBACK
#         <strong>Félicitations, votre chapitre peut être publié en l'état.</strong><br>
#         Votre score est de #{analysis_result[:final_score]} / 70.<br><br>

#         Voici quelques suggestions pour le rendre encore plus génial :<br>
#         1. #{gpt_feedback[1] || "Aucune suggestion supplémentaire disponible."}<br>
#         2. #{gpt_feedback[2] || "Aucune suggestion supplémentaire disponible."}<br>
#         3. #{gpt_feedback[3] || "Aucune suggestion supplémentaire disponible."}<br><br>

#         De plus, votre texte contient les éléments suivants :<br>
#         #{additional_feedback}
#       FEEDBACK
#     else
#       <<~FEEDBACK
#         <strong>Malheureusement, votre chapitre ne peut être publié en l'état.</strong><br>
#         Votre score est de #{analysis_result[:final_score]} / 70, ce qui est trop juste.<br><br>

#         Voici quelques suggestions pour atteindre le score minimal requis :<br>
#         1. #{gpt_feedback[1] || "Aucune suggestion disponible."}<br>
#         2. #{gpt_feedback[2] || "Aucune suggestion disponible."}<br>
#         3. #{gpt_feedback[3] || "Aucune suggestion disponible."}<br><br>

#         De plus, votre texte contient les éléments suivants :<br>
#         #{additional_feedback}
#       FEEDBACK
#     end
#   end

#   def contains_vulgarity?(content)
#     vulgar_words = ["pute", "putes", "connard", "connards", "salope", "enculé", "fils de pute", "salopes", "enculée", "enculées", "enculés"]

#     plain_text_content = if content.respond_to?(:body)
#                           content.body.to_plain_text
#                         else
#                           content.to_s
#                         end

#     vulgar_words.any? { |word| plain_text_content.downcase.include?(word) }
#   end

#   def incorrect_dialogue_format?(content)
#     plain_text_content = if content.respond_to?(:body)
#                           content.body.to_plain_text
#                         else
#                           content.to_s
#                         end

#     plain_text_content.scan(/(?:\w+:|(?:\(.*?\):))/).any?
#   end

#   def excessive_parentheses?(content)
#     plain_text_content = if content.respond_to?(:body)
#                           content.body.to_plain_text
#                         else
#                           content.to_s
#                         end

#     open_parentheses_count = plain_text_content.count('(')
#     close_parentheses_count = plain_text_content.count(')')

#     excessive = open_parentheses_count > 5 || close_parentheses_count > 5

#     excessive
#   end

#   def analyze_text(content)
#     plain_text_content = content.body.to_plain_text
#     puts "Contenu du texte pour analyse : #{plain_text_content}"

#     # 1. Analyse complète via la méthode analyze_text_for_feedback
#     feedback_result = analyze_text_for_feedback(plain_text_content)
#     puts "Feedback additionnel : #{feedback_result}"

#     # 2. Obtenir la note d'intérêt via GPT
#     interest_result = call_gpt_for_interest_score(plain_text_content)
#     puts "Résultat de la note d'intérêt : #{interest_result}"

#     # 3. Feedback détaillé via GPT
#     detailed_feedback_result = call_gpt_for_detailed_feedback(plain_text_content, interest_result[:score])
#     puts "Feedback détaillé : #{detailed_feedback_result}"

#     # Calcul de la moyenne des deux scores
#     final_score = (feedback_result[:score] + interest_result[:score]) / 2.0
#     puts "Score final calculé : #{final_score}"

#     passed = final_score >= 70
#     puts "Texte #{passed ? 'validé' : 'rejeté'} avec un score final de #{final_score}"

#     {
#       readability_score: feedback_result[:score],
#       readability_feedback: feedback_result[:feedback].join("\n"),
#       interest_score: interest_result[:score],
#       interest_feedback: detailed_feedback_result[:feedback],
#       final_score: final_score.round(2),
#       passed: passed
#     }
#   end

#   def analyze_text_for_feedback(content)
#     puts "Analyse additionnelle en cours"
#     feedback = []
#     score = 100

#     # Critère : usage du langage vulgaire
#     if contains_vulgarity?(content)
#       feedback << "Le texte contient un langage vulgaire ou inapproprié."
#       score -= 50
#     end

#     # Critère : format de dialogue incorrect
#     if incorrect_dialogue_format?(content)
#       feedback << "Le texte utilise un format incorrect pour les dialogues."
#       score -= 50
#     end

#     # Critère : usage excessif des parenthèses
#     if excessive_parentheses?(content)
#       feedback << "Le texte contient des parenthèses pour décrire des actions ou des dialogues."
#       score -= 50
#     end

#     spelling_errors = check_spelling(content)
#     grammar_errors = check_grammar(content)
#     conjugation_errors = check_conjugation(content)

#     if conjugation_errors > 0
#       feedback << "Le texte contient #{conjugation_errors} fautes de conjugaison."
#       score -= conjugation_errors * 0.5
#     end

#     if spelling_errors > 0
#       feedback << "Le texte contient #{spelling_errors} fautes d'orthographe."
#       score -= spelling_errors * 0.125
#     end

#     if grammar_errors > 0
#       feedback << "Le texte contient #{grammar_errors} fautes de grammaire."
#       score -= grammar_errors * 0.25
#     end

#     if excessive_repetition?(content)
#       feedback << "Le texte contient trop de répétitions de mots."
#       score -= 20
#     end

#     is_simplistic, long_word_ratio = low_text_complexity?(content)
#     if is_simplistic
#       feedback << "Le vocabulaire est trop simpliste (#{(long_word_ratio * 100).round(2)}% de mots longs)."
#       score -= 20
#     end

#     feedback << "Le texte respecte tous les critères de lisibilité." if feedback.empty?
#     puts "Score et feedback supplémentaires calculés : #{score}, #{feedback}"
#     { score: score, feedback: feedback }
#   end

#   def excessive_repetition?(content)
#     plain_text_content = if content.respond_to?(:body)
#                           content.body.to_plain_text
#                         else
#                           content.to_s
#                         end

#     words = plain_text_content.downcase.scan(/\w+/)
#     word_frequency = words.each_with_object(Hash.new(0)) { |word, freq| freq[word] += 1 }

#     repetition_threshold = 5
#     repeated_words = word_frequency.select { |_, count| count > repetition_threshold }

#     repeated_words.any?
#   end

#   def low_text_complexity?(content)
#     plain_text_content = if content.respond_to?(:body)
#                           content.body.to_plain_text
#                         else
#                           content.to_s
#                         end

#     words = plain_text_content.scan(/\w+/)
#     long_words = words.select { |word| word.length > 6 }

#     long_word_ratio = long_words.size.to_f / words.size
#     is_simplistic = long_word_ratio < 0.10

#     [is_simplistic, long_word_ratio]
#   end

#   def call_gpt_for_interest_score(content)
#     puts "Appel à GPT pour la note d'intérêt"
#     client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

#     prompt = "Donne une note sur 100 pour ce texte. Ne fournis aucune explication, juste la note sous la forme 'Note : XX'. Voici le texte : #{content}"

#     begin
#       response = client.chat(
#         parameters: {
#           model: "gpt-3.5-turbo",
#           messages: [
#             { role: "system", content: "Tu es un critique littéraire spécialisé dans l'évaluation de chapitres de romans." },
#             { role: "user", content: prompt }
#           ],
#           max_tokens: 50
#         }
#       )

#       feedback = response['choices'].first['message']['content']
#       gpt_score = extract_score_from_feedback(feedback)
#       puts "Score d'intérêt calculé par GPT : #{gpt_score}"
#       { score: gpt_score }
#     rescue StandardError => e
#       Rails.logger.error "Erreur OpenAI : #{e.message}"
#       { score: 0 }
#     end
#   end

#   def call_gpt_for_detailed_feedback(content, score)
#     puts "Appel à GPT pour un feedback détaillé"
#     client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

#     prompt = if score < 70
#                 "Le texte suivant a obtenu un score de #{score}/100. Le texte n'est pas adapté pour la publication dans sa forme actuelle. Donne 3 critiques claires et directes sur les principales faiblesses du texte en prenant en compte que ce n'est qu'un seul chapitre d'une histoire plus vaste. Voici le texte : #{content}"
#               else
#                 "Le texte suivant a obtenu un score de #{score}/100. Bien qu'il soit de bonne qualité et publiable, il peut encore être amélioré. Identifie 3 aspects forts du texte et donne une critique précise sur ce qui doit être changé pour en faire un récit exceptionnel en prenant en compte que ce n'est qu'un seul chapitre d'une histoire plus vaste. Voici le texte : #{content}"
#               end

#     begin
#       response = client.chat(
#         parameters: {
#           model: "gpt-3.5-turbo",
#           messages: [
#             { role: "system", content: "Tu es un critique littéraire spécialisé dans l'évaluation de chapitres de romans." },
#             { role: "user", content: prompt }
#           ],
#           max_tokens: 500
#         }
#       )

#       feedback = response['choices'].first['message']['content']
#       puts "Feedback détaillé reçu de GPT : #{feedback}"
#       { feedback: feedback }
#     rescue StandardError => e
#       Rails.logger.error "Erreur OpenAI : #{e.message}"
#       { feedback: "Erreur lors de l'évaluation avec GPT." }
#     end
#   end

#   def extract_score_from_feedback(feedback)
#     puts "Extraction du score de la réponse GPT"
#     if feedback.match(/(\d{1,2})\/100/)
#       feedback.match(/(\d{1,2})\/100/)[1].to_i
#     elsif feedback.match(/(\d{1,2})\/10/)
#       feedback.match(/(\d{1,2})\/10/)[1].to_i * 10
#     elsif feedback.match(/Note\s*[:\-]?\s*(\d{1,2})/)
#       feedback.match(/Note\s*[:\-]?\s*(\d{1,2})/)[1].to_i
#     else
#       feedback.scan(/\d{1,2}/).map(&:to_i).max || 0
#     end
#   end

#   def call_language_tool_api(content)
#     puts "Appel à l'API LanguageTool"
#     responses = Concurrent::Array.new
#     content_chunks = content.scan(/.{1,#{MAX_TEXT_LENGTH}}/m)

#     threads = content_chunks.map do |chunk|
#       Thread.new do
#         uri = URI.parse("https://api.languagetool.org/v2/check")
#         request = Net::HTTP::Post.new(uri)
#         request.set_form_data("text" => chunk, "language" => "fr")

#         response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
#           http.request(request)
#         end

#         responses << JSON.parse(response.body)
#       end
#     end

#     threads.each(&:join)

#     merged_response = { 'matches' => [] }
#     responses.each do |response|
#       merged_response['matches'] += response['matches']
#     end
#     puts "Résultat de l'API LanguageTool : #{merged_response}"
#     merged_response
#   end
# end
