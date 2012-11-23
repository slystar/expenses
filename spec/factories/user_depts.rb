# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_dept do
    from_user_id 1
    to_user_id 1
    amount "9.99"
  end
end
