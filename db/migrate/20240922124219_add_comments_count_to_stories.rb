class AddCommentsCountToStories < ActiveRecord::Migration[7.1]
  def change
    add_column :stories, :comments_count, :integer
  end
end
