class ChangeSuggestedTagsTypeInStories < ActiveRecord::Migration[7.0]
  def change
    change_column :stories, :suggested_tags, :string, array: true, default: [], using: 'string_to_array(suggested_tags, \',\')'
  end
end
