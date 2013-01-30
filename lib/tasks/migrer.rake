namespace :data do
  desc "Data migration tasks"

  task migrate: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

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

          require "#{Rails.root}/db/data_migrate/#{data_migration[:basefilename]}"
          eval(data_migration[:class_name]).run

          t_end = Time.now

          unless data_migration[:processed]
            Migrer::DataMigrationVersion.create(version: version)
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

            require "#{Rails.root}/db/data_migrate/#{v[:basefilename]}"
            eval(v[:class_name]).run

            t_end = Time.now

            Migrer::DataMigrationVersion.create(version: k)

            puts "#{v[:class_name]}: migrated (#{t_end - t_start}s)"
          end
        end
      end
    end
  end

  task mark: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if data_migration[:processed]
          puts "Data migration already processed."
        else
          puts "Data migration #{data_migration[:class_name]} will be marked as processed. Continue? (responses other than 'yes' will exit)"

          prompt = $stdin.gets.chomp

          if prompt == "yes"
            Migrer::DataMigrationVersion.create(version: version)
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
    unprocessed_data_migrations = Migrer::DataMigrationVersion.all_from_files.select { |k, v| !v[:processed] }

    puts "This will mark all data migrations as already processed. Continue? (responses other than 'yes' will exit)"

    prompt = $stdin.gets.chomp
    if prompt == "yes"
      unprocessed_data_migrations.each do |k, v|
        Migrer::DataMigrationVersion.create(version: k)
        puts "#{v[:class_name]}: marked as migrated"
      end
    end
  end

  task unmark: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if !data_migration[:processed]
          puts "Data migration not yet processed."
        else
          puts "Data migration #{data_migration[:class_name]} will be unmarked as processed. Continue? (responses other than 'yes' will exit)"

          prompt = $stdin.gets.chomp

          if prompt == "yes"
            Migrer::DataMigrationVersion.find_by_version(version).destroy
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
      Migrer::DataMigrationVersion.destroy_all
      puts "Data migration records cleared"
    end
  end
end
