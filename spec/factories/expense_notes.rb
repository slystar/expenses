# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_note do
    note "MyText"
    version 1
  end
end
