class CreateReads < ActiveRecord::Migration[7.1]
  def change
    create_table :reads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :story, null: false, foreign_key: true
      t.references :chapter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
