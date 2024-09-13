class MigrateChapterContentToActionText < ActiveRecord::Migration[6.0]
  def up
    Chapter.find_each do |chapter|
      chapter.update!(content: chapter[:content]) if chapter[:content].present?
    end
  end

  def down
    Chapter.find_each do |chapter|
      chapter.update_column(:content, chapter.content.to_plain_text)
    end
  end
end
