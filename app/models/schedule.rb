class Schedule < ApplicationRecord
  belongs_to :user

  validates :title,      presence: true, length: { maximum: 50 }
  validates :content,                    length: { maximum: 1000 }
  validates :start_time, presence: true
  validates :end_time,   presence: true
  validate :end_time_after_start_time
  validates :category_color, presence: true, if: -> { category_name.present? }
  validates :category_name, presence: true, if: -> { category_color.present? }

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time < start_time
      errors.add(:end_time, "は開始時間より後の時間に設定してください")
    end
  end
end
