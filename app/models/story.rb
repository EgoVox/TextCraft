class Story < ApplicationRecord
  include PgSearch::Model

  has_one_attached :cover_image

  belongs_to :user
  belongs_to :category
  has_many :chapters, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :story_tags, dependent: :destroy
  has_many :tags, through: :story_tags

  has_many :reads, dependent: :destroy
  has_many :users_who_read, through: :reads, source: :user

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }


  before_validation :generate_slug, on: :create

  validates :cover_image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'doit être une URL valide' }, allow_blank: true

  pg_search_scope :search_by_title_description_and_tags,
                against: [:title, :description],
                associated_against: {
                  tags: [:name]
                },
                using: {
                  tsearch: { prefix: true } # Le préfixe permet de rechercher des mots partiels
                }


  def to_param
    slug
  end

  def last_read_chapter_for_user(user)
    read = reads.where(user: user).order(created_at: :desc).first
    read ? read.chapter : nil
  end

  def likes_count
    likes.count
  end

  private

  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end

end
