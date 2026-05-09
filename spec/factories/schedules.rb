FactoryBot.define do
  factory :schedule do
    title { "テスト予定" }
    content { "テスト内容" }
    start_time { Time.zone.now.tomorrow.change(hour: 10) }
    end_time { Time.zone.now.tomorrow.change(hour: 11) }
    category_name { "勉強" }
    category_color { "#0000ff" }
    association :user
  end
end
