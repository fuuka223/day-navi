class AddLocationIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :location, :integer, null: true
  end
end
