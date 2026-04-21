class TopsController < ApplicationController
  def index
    if user_signed_in? && current_user.city.present?
    
      weather_data = WeatherService.fetch_weather(current_user.city)
      if weather_data && weather_data['list']
        @forecasts = parse_weather(weather_data) 
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

      if response && response['list']
        forecast_list = response['list']
        next_rain = forecast_list.find do |f|
          weather_main = f.dig('weather', 0, 'main')
          weather_main == 'Rain' || weather_main == 'Snow'
        end
        if next_rain
          @rain_time = Time.zone.parse(next_rain['dt_txt'])
        else
          @rain_time = nil
          Rails.logger.error "天気予報データの取得に失敗しました: #{response}"
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
        # ---2.予定の取得---
        @schedules = current_user.schedules
                             .where(start_time: @date.all_day)
                             .order(:start_time)

        # ---3.天気の取得---
        weather_data = WeatherService.fetch_weather(current_user.city)
        if weather_data && weather_data['list']
          # シンボルキーでハッシュを作成する
          @hourly_forecasts = weather_data['list'].first(8).map do |f|
            time = Time.zone.parse(f['dt_txt'])
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
      date = Time.at(f['dt']).to_date
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
