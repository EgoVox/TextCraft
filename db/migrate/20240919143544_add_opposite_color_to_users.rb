class AddOppositeColorToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :opposite_color, :string
  end
end
