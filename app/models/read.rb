class Read < ApplicationRecord
  belongs_to :user
  belongs_to :story
  belongs_to :chapter, optional: true

  def self.mark_as_read(user, story, chapter = nil)
    find_or_create_by(user: user, story: story, chapter: chapter)
  end
end
