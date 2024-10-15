require 'net/http'
require 'uri'
require 'json'
require 'concurrent'

class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story
  before_action :set_chapter_by_position, only: [:show, :destroy]
  before_action :set_chapter_by_id, only: [:edit, :update]

require 'docx'
require 'pdf-reader'
require 'odf'

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

    # Vérifier s'il y a des pièces jointes via ActionText (dans ActiveStorage)
    if @chapter.content.body.attachments.any?
      attachment = @chapter.content.body.attachments.first

      if valid_attachment?(attachment)
        extracted_text = extract_text_from_attachment(attachment)
        Rails.logger.debug "Session size: #{request.session.to_hash.size}"


        if extracted_text
          @chapter.content = ActionText::Content.new(extracted_text)  # Remplacer le contenu par le texte extrait

          # Supprimer la pièce jointe après l'extraction (en production uniquement)
          attachment.purge if Rails.env.production?
        else
          flash.now[:alert] = "Impossible d'extraire le texte de la pièce jointe."
          return render :new
        end
      else
        flash.now[:alert] = "Seuls les fichiers PDF, DOCX, et ODT sont acceptés."
        return render :new
      end
    end

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

  def valid_attachment?(attachment)
    attachment.content_type.in?(%w(application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.oasis.opendocument.text))
  end

# Méthode pour extraire le texte de la pièce jointe
  def extract_text_from_attachment(attachment)
    if attachment.content_type == 'application/pdf'
      extract_text_from_pdf(attachment)
    elsif attachment.content_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      extract_text_from_docx(attachment)
    elsif attachment.content_type == 'application/vnd.oasis.opendocument.text'
      extract_text_from_odt(attachment)
    end
  end

  def extract_text_from_pdf(attachment)
    begin
      # Télécharge le fichier PDF
      pdf_io = StringIO.new(attachment.download.force_encoding('BINARY'))  # Assure que le contenu est binaire
      reader = PDF::Reader.new(pdf_io)

      text = ''
      reader.pages.each do |page|
        text += page.text.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') + "\n"
      end

      text
    rescue StandardError => e
      Rails.logger.error "Erreur lors de l'extraction du PDF: #{e.message}"
      nil
    end
  end


  def extract_text_from_docx(attachment)
    doc = Docx::Document.open(StringIO.new(attachment.download))
    text = doc.paragraphs.map(&:text).join("\n")
    text
  rescue StandardError => e
    Rails.logger.error "Erreur lors de l'extraction du DOCX: #{e.message}"
    nil
  end

  def extract_text_from_odt(attachment)
    odt = ODF::Text.new(StringIO.new(attachment.download))
    odt.text
  rescue StandardError => e
    Rails.logger.error "Erreur lors de l'extraction de l'ODT: #{e.message}"
    nil
  end

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
    elsif score < 70 && score > 40
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
