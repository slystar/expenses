# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_config do
    user_id 1
    title "MyString"
    description "MyText"
    field_mapping "MyText"
    file_type "MyString"
    unique_id_field "MyString"
    unique_id_hash_fields "MyText"
  end
end
