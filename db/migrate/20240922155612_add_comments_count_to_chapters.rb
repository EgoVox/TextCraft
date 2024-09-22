class AddCommentsCountToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :comments_count, :integer, default: 0, null: false
  end
end
