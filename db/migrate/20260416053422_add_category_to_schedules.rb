class AddCategoryToSchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :schedules, :category_name, :string
    add_column :schedules, :category_color, :string
  end
end
