# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do

  factory :location do |f|
    f.name { Faker::Name.title }
    f.street_number { Faker::Address.building_number }
    f.address { Faker::Address.street_name }
    f.postal_code { Faker::Address.postcode }
    f.latitude { Faker::Address.latitude }
    f.longitude { Faker::Address.longitude }

    factory :location_with_ads do
      after_create do |location|
        create(:ad, location: location)
      end
    end

    # Temporary solution, until I investigate Rspec interaction with Devise.
    f.user_id { Faker::Number.number(1) }
  end

  factory :invalid_location, parent: :location do |f|
    f.postal_code nil
    f.latitude nil
    f.longitude nil
  end

  factory :new_location do |f|
    f.name nil
    f.street_number nil
    f.address nil
    f.city nil
    f.postal_code nil
    f.latitude nil
    f.longitude nil
  end
end