FactoryBot.define do
  factory :location do
    ip_address { Faker::Internet.ip_v4_address }
    url { Faker::Internet.url(host: Faker::Internet.domain_name) }

    geolocation { ActiveRecord::Point.new(Faker::Number.decimal(l_digits: 4, r_digits: 4),
                                          Faker::Number.decimal(l_digits: 4, r_digits: 4)) }
  end
end
