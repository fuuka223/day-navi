class Task < ApplicationRecord
  belongs_to :user

  enum priority_level: { 
    "重要・緊急": 1,
    "重要・非緊急": 2,
    "非重要・緊急": 3,
    "非重要・非緊急": 4
  }

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :priority_level, presence: true
  validates :is_completed, inclusion: {in: [true, false]}
end
