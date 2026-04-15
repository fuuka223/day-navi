require 'net/http'
require 'json'
require 'openssl'

class WeatherService
  API_KEY = ENV['OPENWEATHER_API_KEY']
  BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast'

  def self.fetch_weather(city)
    return nil if city.blank?

    uri = URI("#{BASE_URL}?q=#{city},jp&units=metric&lang=ja&appid=#{API_KEY}")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.get(uri.request_uri)
    end
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "WeatherService Error: #{e.message}"
    nil
  end
end