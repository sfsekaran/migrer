class DataMigrationGenerator < Rails::Generators::NamedBase
  require "rails/generators/active_record"

  source_root File.expand_path('../templates', __FILE__)
  argument :description, type: :string, default: nil, required: false

  def generate_data_migration
    template "data_migration.rb",
             "db/data_migrate/#{file_name}"
  end

  private
  def file_name
    "#{ActiveRecord::Generators::Base.next_migration_number('db/data_migrate')}_#{name.underscore}.rb"
  end
end
