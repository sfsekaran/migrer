require 'data_migration'

namespace :data do
  desc "Data migration tasks"

  task migrate: :environment do
    data_migrations = DataMigration.all

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if data_migration[:processed]
          puts "Data migration already processed. Do you want to run it anyway? (responses other than 'yes' will exit)"
        else
          puts "Starting data migration #{data_migration[:class_name]}. Do you wish to continue? (responses other than 'yes' will exit)"
        end

        prompt = $stdin.gets.chomp

        if prompt == "yes"
          require "#{Rails.root}/lib/tasks/data_migrations/#{data_migration[:basefilename]}"
          eval(data_migration[:class_name]).run

          unless data_migration[:processed]
            ActiveRecord::Base.connection.execute(
                "INSERT INTO data_migration_versions
                 VALUES (NULL, #{version}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )
          end
        end
      end
    else
      data_migrations.each do |k, v|
        unless v[:processed]
          puts "Starting data migration #{v[:class_name]}. Do you wish to continue? (responses other than 'yes' will exit)"
          prompt = $stdin.gets.chomp
          if prompt == "yes"
            require "#{Rails.root}/lib/tasks/data_migrations/#{v[:basefilename]}"
            eval(v[:class_name]).run

            ActiveRecord::Base.connection.execute(
                "INSERT INTO data_migration_versions
                 VALUES (NULL, #{k}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )
          end
        end
      end
    end
  end
end