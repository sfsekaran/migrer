class DataMigrationGenerator < Rails::Generators::NamedBase
  require "rails/generators/active_record"

  source_root File.expand_path('../templates', __FILE__)
  argument :description, type: :string, default: nil, required: false

  def generate_data_migration
    template "data_migration.rb",
             "lib/tasks/data_migrations/#{file_name}"
  end

  private
  def file_name
    "#{ActiveRecord::Generators::Base.next_migration_number('lib/tasks/data_migrations')}_#{name.underscore}.rake"
  end
end
