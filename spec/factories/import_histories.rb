# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_history do
    user_id 1
    import_config_id 1
    original_file_name "MyString"
    new_file_name "MyString"
  end
end
