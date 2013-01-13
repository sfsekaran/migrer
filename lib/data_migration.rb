class DataMigration
  def self.all
    filenames = Dir.entries("#{Rails.root}/lib/tasks/data_migrations").select { |f| /^\d+.*\.rb$/ === f }
    data_migrations = {}

    filenames.each do |f|
      match_data = /^(?<version>\d+)_(?<name>.+)\.rb$/.match(f)

      record = ActiveRecord::Base.connection.execute(
          "SELECT * FROM data_migration_versions WHERE version = '#{match_data[:version]}'").first

      data_migrations.merge!(
          match_data[:version] => {
              basefilename: "#{match_data[:version]}_#{match_data[:name]}",
              class_name: match_data[:name].camelize,
              filename: "#{match_data[:version]}_#{match_data[:name]}.rb",
              name: match_data[:name],
              processed: (record != nil),
              created_at: record.try(:[], :created_at),
              updated_at: record.try(:[], :updated_at)
          })
    end

    data_migrations
  end
end
