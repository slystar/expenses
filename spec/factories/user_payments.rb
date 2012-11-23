# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_payment do
    from_user_id 1
    to_user_id 1
    amount "9.99"
    approved false
    approved_date "2012-11-23 12:34:49"
  end
end
