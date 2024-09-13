class AddCoverImageUrlToStories < ActiveRecord::Migration[7.1]
  def change
    add_column :stories, :cover_image_url, :string
  end
end
