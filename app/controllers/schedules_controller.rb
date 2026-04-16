class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:edit, :update, :destroy]

  def index
    @today_schedules = current_user.schedules.where(start_time: Time.zone.now.all_day)
  end

  def calendar
    @schedules = current_user.schedules
    if current_user.city.present?
      weather_data = WeatherService.fetch_weather(current_user.city)
      @forecasts = parse_weather(weather_data) if weather_data && weather_data['list']
    end
  end

  def new
    @schedule = Schedule.new
    target_date = params[:date] || Date.today.to_s
  
    if params[:start_time] && params[:end_time]
      @schedule.start_time = Time.zone.parse("#{target_date} #{params[:start_time]}")
      @schedule.end_time = Time.zone.parse("#{target_date} #{params[:end_time]}")
    end
  end

  def create
    @schedule = current_user.schedules.new(combine_date_and_time(schedule_params))
    if @schedule.save
      redirect_to schedule_path(@schedule.start_time.to_date.to_s)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    begin
      @date = Date.parse(params[:id])
      @schedules = current_user.schedules.where(start_time: @date.all_day)
    rescue Date::Error
      redirect_to schedules_path, alert: "有効な日付ではありません"
    end
  end

  def edit
  end

  def update
    if @schedule.update(combine_date_and_time(schedule_params))
      redirect_to schedule_path(@schedule.start_time.to_date.to_s)
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
    params.require(:schedule).permit(:title, :content, :start_time, :end_time, :start_date)
  end

  def combine_date_and_time(params)
  return params unless params[:start_date].present?

  date = params[:start_date]
  
  params[:start_time] = Time.zone.parse("#{date} #{params[:start_time]}")
  params[:end_time] = Time.zone.parse("#{date} #{params[:end_time]}")

  params.delete(:start_date) 
  
  params
end
  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end

  def parse_weather(data)
  forecasts = {}
  data['list'].each do |f|
    date = Time.at(f['dt']).to_date
    next if forecasts[date] && Time.at(f['dt']).hour != 12
    forecasts[date] = {
      temp: f['main']['temp'].round,
      description: f['weather'][0]['description'],
      icon: f['weather'][0]['icon']
    }
    end
    forecasts
  end
end
