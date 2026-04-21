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
    @category_options = Schedule.where.not(category_name: [nil, ""])
                              .select(:category_name, :category_color)
                              .distinct
    target_date = params[:date] || Date.today.to_s
  
    if params[:start_time] && params[:end_time]
      @schedule.start_time = Time.zone.parse("#{target_date} #{params[:start_time]}")
      @schedule.end_time = Time.zone.parse("#{target_date} #{params[:end_time]}")
    end
  end

  def create
    start_datetime = Time.zone.parse("#{schedule_params[:start_date]} #{schedule_params[:start_time]}")
    end_datetime = Time.zone.parse("#{schedule_params[:start_date]} #{schedule_params[:end_time]}")
    @schedule = current_user.schedules.new(schedule_params.except(:start_date))
    # 作成した日本時間の時刻を代入
    @schedule.start_time = start_datetime
    @schedule.end_time = end_datetime
    if @schedule.save
      # 保存成功：作成した予定の日付のページへリダイレクト
      redirect_to schedule_path(id: schedule_params[:start_date]), notice: "予定を登録しました"
    else
      # 保存失敗：選択肢を再取得して new 画面を表示
      set_category_options
      render :new, status: :unprocessable_entity
    end
  end

  def show
    begin
      @date = Date.parse(params[:id])
    # ---日本時間の範囲に指定---
      start_of_day = Time.zone.local(@date.year, @date.month, @date.day, 0, 0, 0)
      end_of_day = start_of_day.end_of_day
      @schedules = current_user.schedules.where(start_time: start_of_day..end_of_day).order(:start_time)
      # カテゴリーの選択肢を取得
      set_category_options
      # 今日から3日間以内か判定
      is_within_3_days = @date >= Date.today && @date <= Date.today + 2.days
    
      if is_within_3_days && current_user.city.present?
        weather_data = WeatherService.fetch_weather(current_user.city)
        # 3時間ごとの予報をハッシュ化して取得
        @hourly_forecasts = parse_hourly_weather(weather_data, @date) if weather_data
      end
    rescue Date::Error, TypeError
      redirect_to schedules_path, alert: "有効な日付ではありません"
    end
  end

  def edit
    @category_options = Schedule.where.not(category_name: [nil, ""])
                              .select(:category_name, :category_color)
                              .distinct
  end

  def update
    if @schedule.update(combine_date_and_time(schedule_params))
      redirect_to schedule_path(@schedule.start_time.to_date.to_s)
    else
      set_category_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    deleted_date = @schedule.start_time.to_date.to_s
    @schedule.destroy
    redirect_to schedule_path(deleted_date)
  end

  private

  def schedule_params
    params.require(:schedule).permit(:title, :content, :start_time, :end_time, :start_date, :category_name, :category_color)
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

  def parse_hourly_weather(data, target_date)
    forecasts = []
    # APIの3時間おきのデータをループ
    data['list'].each do |f|
      dt = Time.at(f['dt']).in_time_zone('Tokyo')
      next unless dt.to_date == target_date
      forecasts << {
        start_hour: dt.hour,
        end_hour: dt.hour + 3,
        icon: f['weather'][0]['icon'],
        temp: f['main']['temp'].round,
        condition: f['weather'][0]['main']
      }
    end
    forecasts
  end

  def set_category_options
    @category_options = Schedule.where.not(category_name: [nil, ""])
                              .select(:category_name, :category_color)
                              .distinct
  end
end