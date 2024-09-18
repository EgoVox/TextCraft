class AddAnalysisToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :analysis_score, :integer
    add_column :chapters, :analysis_feedback, :text
  end
end
