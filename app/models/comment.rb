class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :story, counter_cache: true

  validates :content, presence: true
end
