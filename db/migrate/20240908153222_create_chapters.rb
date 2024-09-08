class CreateChapters < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters do |t|
      t.string :title
      t.text :content
      t.references :story, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
