FactoryBot.define do
  factory :task do
    title           { Faker::Lorem.characters(number: 50) }
    content         { Faker::Lorem.characters(number: 1000) }
    priority_level  { [1, 2, 3, 4].sample }
    deadline        { Faker::Time.forward(days: 7) }
    is_completed    { false }
    
    association :user
  end
end