require 'migrer/ansi_colors'

namespace :data do

  desc 'Run all unprocessed data migrations or a single data migration if VERSION is specified.'
  task migrate: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?

        can_migrate = !Migrer.paranoid?
        if Migrer.paranoid?
          if data_migration[:processed]
            puts "Data migration already processed. Do you want to run it anyway? (responses other than 'yes' will exit)".migrer_yellow
          else
            puts "Starting data migration #{data_migration[:class_name]}. Do you wish to continue? (responses other than 'yes' will exit)".migrer_yellow
          end
          prompt = $stdin.gets.chomp
          can_migrate = prompt == "yes"
        end

        if can_migrate
          puts "#{data_migration[:class_name]}".migrer_yellow + ": migrating"
          t_start = Time.now

          require "#{Rails.root}/db/data_migrate/#{data_migration[:basefilename]}"
          eval(data_migration[:class_name]).run

          t_end = Time.now

          unless data_migration[:processed]
            Migrer::DataMigrationVersion.create(version: version)
          end

          puts "#{data_migration[:class_name]}:" + " migrated (#{t_end - t_start}s)".migrer_green
        end
      else
        puts "No data migration found matching version: #{version}".migrer_red
      end
    else
      data_migrations.each do |k, v|
        unless v[:processed]
          can_migrate = !Migrer.paranoid?

          if Migrer.paranoid?
            puts "Starting data migration #{v[:class_name]}. Do you wish to continue? (responses other than 'yes' will exit)".migrer_yellow
            prompt = $stdin.gets.chomp
            can_migrate = prompt == "yes"
          end

          if can_migrate
            puts "#{v[:class_name]}".migrer_yellow + ": migrating"
            t_start = Time.now

            require "#{Rails.root}/db/data_migrate/#{v[:basefilename]}"
            eval(v[:class_name]).run

            t_end = Time.now

            Migrer::DataMigrationVersion.create(version: k)

            puts "#{v[:class_name]}:" + " migrated (#{t_end - t_start}s)".migrer_green
          end
        end
      end
    end
  end

  desc 'Mark a single migration as already processed (requires VERSION).'
  task mark: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if data_migration[:processed]
          puts "Data migration already processed.".migrer_yellow
        else
          can_migrate = !Migrer.paranoid?

          if Migrer.paranoid?
            puts "Data migration #{data_migration[:class_name]} will be marked as processed. Continue? (responses other than 'yes' will exit)".migrer_yellow
            prompt = $stdin.gets.chomp
            can_migrate = prompt == "yes"
          end

          if can_migrate
            Migrer::DataMigrationVersion.create(version: version)
            puts "#{data_migration[:class_name]}:" + " marked as migrated".migrer_green
          end
        end
      else
        puts "No data migration found matching version: #{version}".migrer_red
      end
    else
      puts "VERSION must be supplied.".migrer_red
    end
  end

  desc 'Mark all data migrations as already processed.'
  task mark_all: :environment do
    unprocessed_data_migrations = Migrer::DataMigrationVersion.all_from_files.select { |k, v| !v[:processed] }

    can_migrate = !Migrer.paranoid?

    if Migrer.paranoid?
      puts "This will mark all data migrations as already processed. Continue? (responses other than 'yes' will exit)".migrer_yellow
      prompt = $stdin.gets.chomp
      can_migrate = prompt == "yes"
    end

    if can_migrate
      unprocessed_data_migrations.each do |k, v|
        Migrer::DataMigrationVersion.create(version: k)
        puts "#{v[:class_name]}:" + " marked as migrated".migrer_green
      end
    end
  end

  desc 'Revert a data migration to an unprocessed state (requires VERSION).'
  task unmark: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files

    if (version = ENV['VERSION'])
      data_migration = data_migrations[version]

      if data_migration.present?
        if !data_migration[:processed]
          puts "Data migration not yet processed.".migrer_yellow
        else
          can_migrate = !Migrer.paranoid?

          if Migrer.paranoid?
            puts "Data migration #{data_migration[:class_name]} will be unmarked as processed. Continue? (responses other than 'yes' will exit)".migrer_yellow
            prompt = $stdin.gets.chomp
            can_migrate = prompt == "yes"
          end

          if can_migrate
            Migrer::DataMigrationVersion.find_by_version(version).destroy
            puts "#{data_migration[:class_name]}:" + " unmarked as migrated".migrer_green
          end
        end
      else
        puts "No data migration found matching version: #{version}".migrer_red
      end
    else
      puts "VERSION must be supplied.".migrer_red
    end
  end

  desc 'Revert all data migrations to an unprocessed state.'
  task unmark_all: :environment do
    can_migrate = !Migrer.paranoid?

    if Migrer.paranoid?
      puts "All data migrations will be unmarked as processed. Continue? (responses other than 'yes' will exit)".migrer_yellow
      prompt = $stdin.gets.chomp
      can_migrate = prompt == "yes"
    end

    if can_migrate
      Migrer::DataMigrationVersion.destroy_all
      puts "Data migration records cleared".migrer_green
    end
  end

  desc 'View all unprocessed data migrations by filename.'
  task pending: :environment do
    data_migrations = Migrer::DataMigrationVersion.all_from_files
    pending = data_migrations.reject {|k, v| v[:processed]}

    if data_migrations.present?
      if pending.present?
        puts "The following migrations have not yet been processed:".migrer_yellow
        pending.each do |k, v|
          puts v[:filename]
        end
      else
        puts "All existing data migrations have been processed.".migrer_yellow
      end
    else
      puts "No data migrations found.".migrer_yellow
    end
  end
end
