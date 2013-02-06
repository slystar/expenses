# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_datum do
    user_id 1
    import_history_id 1
    import_config_id 1
    unique_id "MyString"
    unique_hash "MyString"
    mapped_fields "MyText"
    process_flag false
    process_date "2013-02-06 12:40:32"
    expense_id 1
    process_notes "MyText"
  end
end
