class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:edit, :update, :destroy]

  def index
    @today_schedules = current_user.schedules.where(start_time: Time.zone.now.all_day)
  end

  def calendar
    @schedules = current_user.schedules
  end

  def new
    @schedule = Schedule.new
    @schedule.start_time = params[:start_date] if params[:start_date]
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      redirect_to calendar_schedules_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if params[:id].match?(/\A\d{4}-\d{2}-\d{2}\z/)
      @selected_date = params[:id].to_date
      @schedules = current_user.schedules.where(start_time: @selected_date.all_day)
    else
      @schedule = current_user.schedules.find(params[:id])
      @selected_date = @schedule.start_time.to_date
      @schedules = current_user.schedules.where(start_time: @selected_date.all_day)
    end
  end

  def edit
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to schedule_path(@schedule)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to calendar_schedules_path
  end

  private

  def schedule_params
    params.require(:schedule).permit(:title, :content, :start_time, :end_time)
  end

  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end
end
