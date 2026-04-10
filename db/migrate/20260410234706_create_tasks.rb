class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :content
      t.integer :priority_level
      t.boolean :is_completed
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
