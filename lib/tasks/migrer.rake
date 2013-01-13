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
          puts "#{data_migration[:class_name]}: migrating"
          t_start = Time.now

          require "#{Rails.root}/lib/tasks/data_migrations/#{data_migration[:basefilename]}"
          eval(data_migration[:class_name]).run

          t_end = Time.now

          unless data_migration[:processed]
            ActiveRecord::Base.connection.execute(
                "INSERT INTO data_migration_versions
                 VALUES (NULL, '#{version}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )
          end

          puts "#{data_migration[:class_name]}: migrated (#{t_end - t_start}s)"
        end
      else
        puts "No data migration found matching version: #{version}"
      end
    else
      data_migrations.each do |k, v|
        unless v[:processed]
          puts "Starting data migration #{v[:class_name]}. Do you wish to continue? (responses other than 'yes' will exit)"
          prompt = $stdin.gets.chomp
          if prompt == "yes"
            puts "#{v[:class_name]}: migrating"
            t_start = Time.now

            require "#{Rails.root}/lib/tasks/data_migrations/#{v[:basefilename]}"
            eval(v[:class_name]).run

            t_end = Time.now

            ActiveRecord::Base.connection.execute(
                "INSERT INTO data_migration_versions
                 VALUES (NULL, '#{k}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )

            puts "#{v[:class_name]}: migrated (#{t_end - t_start}s)"
          end
        end
      end
    end
  end

  task mark: :environment do
    data_migrations = DataMigration.all

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if data_migration[:processed]
          puts "Data migration already processed."
        else
          puts "Data migration #{data_migration[:class_name]} will be marked as processed. Continue? (responses other than 'yes' will exit)"

          prompt = $stdin.gets.chomp

          if prompt == "yes"
            ActiveRecord::Base.connection.execute(
                "INSERT INTO data_migration_versions
                 VALUES (NULL, '#{version}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )

            puts "#{data_migration[:class_name]}: marked as migrated"
          end
        end
      else
        puts "No data migration found matching version: #{version}"
      end
    else
      puts "VERSION must be supplied."
    end
  end

  task mark_all: :environment do
    unprocessed_data_migrations = DataMigration.all.select { |k, v| !v[:processed] }

    puts "This will mark all data migrations as already processed. Continue? (responses other than 'yes' will exit)"

    prompt = $stdin.gets.chomp
    if prompt == "yes"
      unprocessed_data_migrations.each do |k, v|
        ActiveRecord::Base.connection.execute(
            "INSERT INTO data_migration_versions
             VALUES (NULL, '#{k}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)" )

        puts "#{v[:class_name]}: marked as migrated"
      end
    end
  end

  task unmark: :environment do
    data_migrations = DataMigration.all

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if !data_migration[:processed]
          puts "Data migration not yet processed."
        else
          puts "Data migration #{data_migration[:class_name]} will be unmarked as processed. Continue? (responses other than 'yes' will exit)"

          prompt = $stdin.gets.chomp

          if prompt == "yes"
            ActiveRecord::Base.connection.execute(
                "DELETE FROM data_migration_versions
                 WHERE version = '#{version}'" )

            puts "#{data_migration[:class_name]}: unmarked as migrated"
          end
        end
      else
        puts "No data migration found matching version: #{version}"
      end
    else
      puts "VERSION must be supplied."
    end
  end

  task unmark_all: :environment do
    puts "All data migrations will be unmarked as processed. Continue? (responses other than 'yes' will exit)"

    prompt = $stdin.gets.chomp

    if prompt == "yes"
      ActiveRecord::Base.connection.execute(
          "DELETE FROM data_migration_versions" )

      puts "Data migration records cleared"
    end
  end
end
