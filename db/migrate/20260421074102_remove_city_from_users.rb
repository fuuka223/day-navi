class RemoveCityFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :city, :string
  end
end
