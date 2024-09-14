class AddFeedbackToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :feedback, :text
  end
end
