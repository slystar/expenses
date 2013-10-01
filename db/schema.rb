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

ActiveRecord::Schema.define(:version => 20131001162537) do

  create_table "backups", :force => true do |t|
    t.datetime "backup_date"
    t.integer  "backup_dir_size_KB"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "app_version"
  end

  create_table "expense_notes", :force => true do |t|
    t.text     "note"
    t.integer  "version",     :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "app_version"
  end

  create_table "expenses", :force => true do |t|
    t.date     "date_purchased",                                                                    :null => false
    t.text     "description"
    t.integer  "pay_method_id",                                                                     :null => false
    t.integer  "reason_id",                                                                         :null => false
    t.integer  "store_id",                                                                          :null => false
    t.integer  "user_id",                                                                           :null => false
    t.integer  "group_id",                                                                          :null => false
    t.decimal  "amount",                          :precision => 10, :scale => 2, :default => 0.0
    t.date     "process_date"
    t.boolean  "process_flag",                                                   :default => false
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.string   "duplication_check_hash"
    t.boolean  "duplication_check_reviewed",                                     :default => false
    t.datetime "duplication_check_reviewed_date"
    t.boolean  "duplication_check_processed",                                    :default => false
    t.integer  "expense_note_id"
    t.string   "affected_users"
    t.integer  "app_version"
  end

  add_index "expenses", ["duplication_check_hash"], :name => "index_expenses_on_duplication_check_hash"
  add_index "expenses", ["duplication_check_processed"], :name => "index_expenses_on_duplication_check_processed"
  add_index "expenses", ["user_id"], :name => "index_expenses_on_user_id"

  create_table "group_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["user_id"], :name => "index_group_members_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "display_order"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "hidden",        :default => false
    t.integer  "app_version"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"

  create_table "import_configs", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "field_mapping"
    t.string   "file_type"
    t.string   "unique_id_field"
    t.text     "unique_id_hash_fields"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "date_type"
    t.integer  "app_version"
    t.integer  "pay_method_id"
  end

  add_index "import_configs", ["user_id"], :name => "index_import_configs_on_user_id"

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
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "approved"
    t.integer  "app_version"
  end

  add_index "import_data", ["unique_hash"], :name => "index_import_data_on_unique_hash"
  add_index "import_data", ["unique_id"], :name => "index_import_data_on_unique_id"
  add_index "import_data", ["user_id", "process_flag"], :name => "index_import_data_on_user_id_and_process_flag"
  add_index "import_data", ["user_id"], :name => "index_import_data_on_user_id"

  create_table "import_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "import_config_id"
    t.string   "original_file_name"
    t.string   "new_file_name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "app_version"
  end

  add_index "import_histories", ["user_id"], :name => "index_import_histories_on_user_id"

  create_table "pay_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "pay_methods", ["name"], :name => "index_pay_methods_on_name"

  create_table "payment_notes", :force => true do |t|
    t.integer  "user_payment_id"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "app_version"
    t.boolean  "deleted",         :default => false
  end

  create_table "reasons", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "reasons", ["name"], :name => "index_reasons_on_name"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "stores", :force => true do |t|
    t.string   "name",                       :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "app_version"
    t.integer  "parent_id",   :default => 0
  end

  add_index "stores", ["name"], :name => "index_stores_on_name"

  create_table "update_balance_histories", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "update_balance_histories", ["user_id"], :name => "index_update_balance_histories_on_user_id"

  create_table "user_balances", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "current",                   :default => false
    t.integer  "update_balance_history_id"
    t.integer  "app_version"
    t.integer  "reverse_balance_id",        :default => 0
  end

  add_index "user_balances", ["amount"], :name => "index_user_balances_on_amount"
  add_index "user_balances", ["current"], :name => "index_user_balances_on_current"
  add_index "user_balances", ["from_user_id"], :name => "index_user_balances_on_from_user_id"
  add_index "user_balances", ["to_user_id"], :name => "index_user_balances_on_to_user_id"

  create_table "user_depts", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "process_flag",              :default => false
    t.integer  "expense_id"
    t.datetime "process_date"
    t.integer  "update_balance_history_id"
    t.integer  "app_version"
  end

  add_index "user_depts", ["from_user_id"], :name => "index_user_depts_on_from_user_id"
  add_index "user_depts", ["process_flag"], :name => "index_user_depts_on_process_flag"
  add_index "user_depts", ["to_user_id"], :name => "index_user_depts_on_to_user_id"

  create_table "user_payments", :force => true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.decimal  "amount"
    t.boolean  "approved",                  :default => false
    t.datetime "approved_date"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "process_flag",              :default => false
    t.datetime "process_date"
    t.integer  "update_balance_history_id"
    t.integer  "app_version"
    t.integer  "waiting_on_user_id"
  end

  add_index "user_payments", ["from_user_id"], :name => "index_user_payments_on_from_user_id"
  add_index "user_payments", ["process_flag", "approved"], :name => "index_user_payments_on_process_flag_and_approved"
  add_index "user_payments", ["to_user_id"], :name => "index_user_payments_on_to_user_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.text     "note"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "app_version"
  end

  add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"
  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "user_name",       :null => false
    t.string   "password_digest", :null => false
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "app_version"
  end

  add_index "users", ["user_name"], :name => "index_users_on_user_name"

end
