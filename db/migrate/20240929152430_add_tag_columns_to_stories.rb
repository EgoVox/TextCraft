class AddTagColumnsToStories < ActiveRecord::Migration[7.1]
  def change
    add_column :stories, :suggested_tags, :string
    add_column :stories, :predifined_tags, :string
  end
end
