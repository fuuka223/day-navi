class AddDetailsToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :deadline, :datetime
    change_column_default :tasks, :is_completed, from: nil, to: false
  end
end
