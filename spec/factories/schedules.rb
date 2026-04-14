FactoryBot.define do
  factory :schedule do
    title      { Faker::Lorem.sentence }
    content    { Faker::Lorem.paragraph }
    start_time { Faker::Time.between(from: DateTime.now, to: DateTime.now + 1.day) }
    end_time   { start_time + 1.hour }
    association :user
  end
end
