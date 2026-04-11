class Task < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :priority_level, presence: true, inclusion: {in: 1..4 }
  validates :is_completed, inclusion: {in: true, false}
end
