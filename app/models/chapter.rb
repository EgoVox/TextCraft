class Chapter < ApplicationRecord
  belongs_to :story
  after_save :update_story_timestamp

  before_create :set_position
  after_destroy :reorder_positions

  has_many :reads, dependent: :destroy
  has_many :users_who_read, through: :reads, source: :user
  # has_many :comments, dependent: :destroy

  validates :position, uniqueness: { scope: :story_id }

  private

  def update_story_timestamp
    story.touch
  end

  def set_position
    # max_position = story.chapters.maximum(:position)
  self.position ||= story.chapters.maximum(:position).to_i + 1
  end

  def reorder_positions
    story.chapters.order(:position).each_with_index do |chapter, index|
      chapter.update(position: index + 1)
    end
  end
end
