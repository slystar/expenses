require 'faker'

FactoryGirl.define do
    factory :expense do |f|
	f.date_purchased {Time.now}
	f.description {Faker::Name.name}
	f.pay_method_id 1
	f.reason_id 1
	#f.association :store_id, :factory => :store
	f.store_id {FactoryGirl.build(:store)}
	f.user_id 1
	f.group_id 1
	f.amount 10
    end
end
