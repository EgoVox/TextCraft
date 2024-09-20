class AddPrimaryColorToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :primary_color, :string
  end
end
