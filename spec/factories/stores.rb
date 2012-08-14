require 'faker'

FactoryGirl.define do
    factory :store do |f|
	f.name { Faker::Company.name }
    end
end
