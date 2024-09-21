class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :stories
  has_many :comments
  has_many :likes

  has_many :reads, dependent: :destroy
  has_many :read_stories, through: :reads, source: :story
  has_many :read_chapters, through: :reads, source: :chapte

  validates :first_name, :last_name, :city, :gender, presence: true, allow_blank: true
end
