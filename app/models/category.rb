class Category < ApplicationRecord
  has_many :stories

  validates :name, presence: true

  before_save :generate_slug

  def to_param
    slug  # Utilise le slug pour les URL au lieu de l'ID
  end

  private

  def generate_slug
    self.slug = name.parameterize  # Génère un slug à partir du nom
  end
end
