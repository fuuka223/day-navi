class TopsController < ApplicationController
  def index
    if user_signed_in? && current_user.location.present?
    
      weather_data = WeatherService.fetch_weather(current_user.location)
      if weather_data && weather_data['list']
        @forecasts = parse_weather(weather_data)
        today_all_data = weather_data['list'].select do |f|
          Time.at(f['dt']).in_time_zone('Tokyo').to_date == Time.zone.today
        end
        if today_all_data.any?
          # --- 左上に表示するための集計データ ---
          @today_summary = {
            max_temp:   today_all_data.map { |f| f.dig('main', 'temp_max') }.max.round,
            min_temp:   today_all_data.map { |f| f.dig('main', 'temp_min') }.min.round,
            max_wind:   today_all_data.map { |f| f.dig('wind', 'speed') }.max.round(1),
            total_rain: today_all_data.map { |f| f.dig('rain', '3h') || 0 }.sum.round(1)
          }
        end
      end
    

      if user_signed_in?
        base_tasks = current_user.tasks.where(is_completed: false)
        raw_counts = base_tasks.group(:priority_level).count
        @task_counts_by_index = {}
        raw_counts.each do |key, count|
          level = Task.priority_levels[key] || key.to_i
          @task_counts_by_index[level] = count if level > 0
        end
      end

      if weather_data && weather_data['list']
        forecast_list = weather_data['list']
        next_rain = forecast_list.find do |f|
          weather_main = f.dig('weather', 0, 'main')
          weather_main == 'Rain' || weather_main == 'Snow'
        end
        if next_rain
          @rain_time = Time.at(next_rain['dt']).in_time_zone('Tokyo')
        else
          @rain_time = nil
          Rails.logger.error "天気予報データの取得に失敗しました: #{weather_data}"
        end
      end

      if user_signed_in?
        @next_schedule = current_user.schedules
                                 .where("start_time > ?", Time.current)
                                 .order(start_time: :asc)
                                 .first
      end
      
      @date = Time.zone.today
      @schedules = []
      @hourly_forecasts = []  
      if user_signed_in?
        # ---予定の取得---
        @schedules = current_user.schedules
                             .where(start_time: @date.all_day)
                             .order(:start_time)

        # ---天気---
        if weather_data && weather_data['list']
          # シンボルキーでハッシュを作成する
          @hourly_forecasts = weather_data['list'].first(8).map do |f|
            time = Time.at(f['dt']).in_time_zone('Tokyo')
            {
              start_hour: time.hour,
              temp: f.dig('main', 'temp').round,
              condition: f.dig('weather', 0, 'main') || "clear",
              icon: f.dig('weather', 0, 'icon')
            }
          end
        end
      end
    end
  end

  def parse_weather(data)
    return {} if data.nil? || data['list'].nil?

    forecasts = {}
    data['list'].each do |f|
      date = Time.at(f['dt']).in_time_zone('Tokyo').to_date
      next if forecasts[date] && Time.at(f['dt']).hour != 12

      forecasts[date] = {
        temp: f['main']['temp'].round,
        feels_like: f['main']['feels_like'].round, # 体感温度を追加
        temp_min: f['main']['temp_min'].round,   # 最低気温
        temp_max: f['main']['temp_max'].round,   # 最高気温
        pop: (f['pop'] * 100).round,             # 降水確率(%)
        wind: f['wind']['speed'],                # 風速
        icon: f['weather'][0]['icon'],
        description: f['weather'][0]['description']
      }
    end
    forecasts
  end
end
