class TopsController < ApplicationController
  def index
    if user_signed_in?
      @tasks = current_user.tasks.order(created_at: :desc).limit(5)
      @today_schedules = current_user.schedules.where(start_time: Time.zone.now.all_day).order(:start_time)
    end
  end
end
