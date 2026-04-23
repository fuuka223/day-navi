class AddLocationIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :location, null: true, foreign_key: true
  end
end
