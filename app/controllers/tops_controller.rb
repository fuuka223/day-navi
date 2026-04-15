class TopsController < ApplicationController
  def index
    if user_signed_in?
      @tasks = current_user.tasks
                           .where(deadline: Time.zone.now.all_day, is_completed: false)
                           .order(deadline: :asc)
      
      @today_schedules = current_user.schedules
                                     .where(start_time: Time.zone.now.all_day)
                                     .order(:start_time)
    end
  end
end
