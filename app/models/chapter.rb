class Chapter < ApplicationRecord
  has_rich_text :content

  belongs_to :story
  after_save :update_story_timestamp

  before_create :set_position
  after_destroy :reorder_positions

  has_many :reads, dependent: :destroy
  has_many :users_who_read, through: :reads, source: :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :position, uniqueness: { scope: :story_id }

  def previous_chapter
    story.chapters.where("position < ?", self.position).order(position: :desc).first
  end

  def next_chapter
    story.chapters.where("position > ?", self.position).order(position: :asc).first
  end

  def reading_time
    word_count = self.content.to_plain_text.split.size
    minutes = (word_count / 200.0).ceil

    if minutes < 60
      "#{minutes} minute#{'s' if minutes > 1}"
    else
      hours = minutes / 60
      remaining_minutes = minutes % 60
      "#{hours} hour#{'s' if hours > 1} #{remaining_minutes} minute#{'s' if remaining_minutes > 1}"
    end
  end

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
