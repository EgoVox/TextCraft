class CreateStories < ActiveRecord::Migration[7.1]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
  end
end
