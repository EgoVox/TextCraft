class HomeController < ApplicationController
  def index
    @categories = Category.includes(stories: :likes)
                          .map do |category|
      {
        category: category,
        popular_story: category.stories.joins(:likes).group('stories.id').order('COUNT(likes.id) DESC').first
      }
    end.select { |data| data[:popular_story].present? } # Ne garder que les catégories avec une histoire populaire
  end
end
