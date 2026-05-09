class Schedule < ApplicationRecord
  belongs_to :user

  validates :title,      presence: true, length: { maximum: 50 }
  validates :content,                    length: { maximum: 1000 }, allow_blank: true
  validates :start_time, presence: true
  validates :end_time,   presence: true
  validate :end_time_after_start_time
  validate :time_interval_at_least_15_minutes
  validate :no_time_overlap
  validates :category_color, presence: true, if: -> { category_name.present? }
  validates :category_name, presence: false, if: -> { category_color.present? }

  before_validation :set_default_or_past_color

  private

  def end_time_after_start_time
    return if user.nil? || end_time.blank? || start_time.blank?

    if end_time < start_time
      errors.add(:end_time, "は開始時間より後の時間に設定してください")
    end
  end

  def time_interval_at_least_15_minutes
    return if user.nil? || end_time.blank? || start_time.blank?
    if (end_time - start_time) < 15.minutes
      errors.add(:end_time, "は開始時間から15分以上間隔を空けてください")
    end
  end

  def no_time_overlap
    return if user.nil? || end_time.blank? || start_time.blank?
    overlapping_schedules = user.schedules.where.not(id: id)
    overlap = overlapping_schedules.any? do |s|
      (start_time < s.end_time) && (s.start_time < end_time)
    end
    errors.add(:base, "入力された時間は既に存在する予定と重複しています") if overlap
  end

  def set_default_or_past_color
  if category_name.present? && category_color.blank?
    past_color = user.schedules.where(category_name: category_name).last&.category_color
    self.category_color = past_color || "#f8f9fa"
  elsif category_name.blank?
    self.category_color = "#f8f9fa"
  end
end
end
