class Story < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :chapters, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :reads, dependent: :destroy
  has_many :users_who_read, through: :reads, source: :user

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  def to_param
    slug
  end

  def last_read_chapter_for_user(user)
    read = reads.where(user: user).order(created_at: :desc).first
    read ? read.chapter : nil
  end

  private

  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end

end
