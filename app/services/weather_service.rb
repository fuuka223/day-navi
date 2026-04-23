require 'net/http'
require 'json'
require 'openssl'

class WeatherService
  API_KEY = ENV['OPENWEATHER_API_KEY']
  BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast'

  def self.fetch_weather(location)
    return nil if location.nil? || location.latitude.blank? || location.longitude.blank?

    uri = URI("#{BASE_URL}?lat=#{location.latitude}&lon=#{location.longitude}&units=metric&lang=ja&appid=#{API_KEY}")

    verify_mode = Rails.env.development? ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: verify_mode) do |http|
      http.get(uri.request_uri)
    end

    if response.code == "200"
      JSON.parse(response.body)
    else
      Rails.logger.error "WeatherService Error: Response Code #{response.code}, Body: #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "WeatherService Error: #{e.message}"
    nil
  end
end