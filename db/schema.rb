# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130307182123) do

  create_table "backups", :force => true do |t|
    t.datetime "backup_date"
    t.integer  "backup_dir_size_KB"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expense_notes", :force => true do |t|
    t.text     "note"
    t.integer  "version",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expenses", :force => true do |t|
    t.date     "date_purchased",                                     :null => false
    t.text     "description"
    t.integer  "pay_method_id",                                      :null => false
    t.integer  "reason_id",                                          :null => false
    t.integer  "store_id",                                           :null => false
    t.integer  "user_id",                                            :null => false
    t.integer  "group_id",                                           :null => false
    t.decimal  "amount",                          :default => 0.0
    t.date     "process_date"
    t.boolean  "process_flag",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "duplication_check_hash"
    t.boolean  "duplication_check_reviewed",      :default => false
    t.datetime "duplication_check_reviewed_date"
    t.boolean  "duplication_check_processed",     :default => false
    t.integer  "expense_note_id"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_configs", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "field_mapping"
    t.string   "file_type"
    t.string   "unique_id_field"
    t.text     "unique_id_hash_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "date_type"
  end

  create_table "import_data", :force => true do |t|
    t.integer  "user_id"
    t.integer  "import_history_id"
    t.integer  "import_config_id"
    t.string   "unique_id"
    t.string   "unique_hash"
    t.text     "mapped_fields"
    t.boolean  "process_flag",      :default => false
    t.datetime "process_date"
    t.integer  "expense_id"
    t.text     "process_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved"
  end

  create_table "import_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "import_config_id"
    t.string   "original_file_name"
    t.string   "new_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pay_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notes", :force => true do |t|
    t.integer  "user_payment_id"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reasons", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stores", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "update_balance_histories", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_balances", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "previous_user_balance_id",  :default => 0
    t.boolean  "current",                   :default => false
    t.integer  "update_balance_history_id"
  end

  create_table "user_depts", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "process_flag",              :default => false
    t.integer  "expense_id"
    t.datetime "process_date"
    t.integer  "update_balance_history_id"
  end

  create_table "user_payments", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.boolean  "approved",                  :default => false
    t.datetime "approved_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "process_flag",              :default => false
    t.datetime "process_date"
    t.integer  "update_balance_history_id"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "user_name",       :null => false
    t.string   "password_digest", :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
