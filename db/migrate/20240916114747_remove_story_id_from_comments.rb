class RemoveStoryIdFromComments < ActiveRecord::Migration[7.1]
  def change
    remove_column :comments, :story_id, :integer
  end
end
