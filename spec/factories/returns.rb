# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :return do
    expense_id 1
    amount "9.99"
    description "MyText"
    user_id 1
    tranaction_date "2015-03-18"
  end
end
