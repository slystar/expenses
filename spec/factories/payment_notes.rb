# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_note do
    user_payment_id 1
    user_id 1
    note "MyText"
  end
end
