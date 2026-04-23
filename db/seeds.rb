# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

puts "福岡県の市区町村代表地点を抽出してインポートを開始します..."

csv_path = Rails.root.join('db', 'csv', 'fukuoka_locations.csv')

registered_cities = []
count = 0

CSV.foreach(csv_path, headers: false) do |row|
  city_name = row[1]
  lat       = row[8]
  lon       = row[9]

  if city_name.present? && !registered_cities.include?(city_name)
    Location.create!(
      city: city_name,
      latitude: lat,
      longitude: lon
    )
    
    registered_cities << city_name
    count += 1
    puts "#{count}件目: #{city_name} を登録しました"
  end
end

puts "----------------------------------------"
puts "インポート完了！"
puts "福岡県内の #{count} 市区町村を登録しました。"
puts "----------------------------------------"