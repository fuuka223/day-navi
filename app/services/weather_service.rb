require 'net/http'
require 'json'

class WeatherService
  API_KEY = ENV['OPENWEATHER_API_KEY']
  BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast'

  def self.fetch_weather(city)
    return nil if city.blank?

    uri = URI("#{BASE_URL}?q=#{city},jp&units=metric&lang=ja&appid=#{API_KEY}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue => e
    Rails.logger.error "WeatherService Error: #{e.message}"
    nil
  end
end