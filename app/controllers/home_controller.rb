class HomeController < ApplicationController
  def index
    @stories = Story.joins(:likes).group('stories.id').order('COUNT(likes.id) DESC').limit(5)
  end
end
