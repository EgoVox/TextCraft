class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by(slug: params[:id])
    @stories = @category.stories.order(created_at: :desc)
  end
end
