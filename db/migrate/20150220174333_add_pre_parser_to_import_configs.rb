class AddPreParserToImportConfigs < ActiveRecord::Migration
  def change
    add_column :import_configs, :pre_parser, :string
  end
end
