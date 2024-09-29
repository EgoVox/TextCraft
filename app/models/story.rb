class Story < ApplicationRecord
  include PgSearch::Model

  has_one_attached :cover_image

  belongs_to :user
  belongs_to :category
  has_many :chapters, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :story_tags, dependent: :destroy
  has_many :tags, through: :story_tags # Les tags prédéfinis sont gérés via cette relation

  has_many :reads, dependent: :destroy
  has_many :users_who_read, through: :reads, source: :user

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }
  validate :total_tags_limit # Validation du nombre total de tags (prédéfinis et suggérés)

  before_validation :generate_slug, on: :create

  # Validation de l'URL de l'image de couverture
  validates :cover_image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'doit être une URL valide' }, allow_blank: true

  # Recherche par titre, description et tags
  pg_search_scope :search_by_title_description_and_tags,
                  against: [:title, :description],
                  associated_against: {
                    tags: [:name]
                  },
                  using: {
                    tsearch: { prefix: true } # Le préfixe permet de rechercher des mots partiels
                  }

  # Paramètre pour le slug
  def to_param
    slug
  end

  # Récupérer le dernier chapitre lu par un utilisateur
  def last_read_chapter_for_user(user)
    read = reads.where(user: user).order(created_at: :desc).first
    read ? read.chapter : nil
  end

  # Compter les likes
  def likes_count
    likes.count
  end

  # Compter tous les commentaires (sur l'histoire et les chapitres)
  def total_comments_count
    story_comments_count = comments.size
    chapter_comments_count = chapters.joins(:comments).count('comments.id')
    story_comments_count + chapter_comments_count
  end

  # Valider le nombre total de tags (prédéfinis et suggérés)
  def total_tags_limit
    total_tags_count = (suggested_tags || []).size + tags.size
    errors.add(:base, "Le total des tags ne peut pas dépasser 8") if total_tags_count > 8
  end

  private

  # Générer le slug à partir du titre si non défini
  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end
end
