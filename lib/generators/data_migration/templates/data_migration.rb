namespace :data_migration do
  <%= description.present? ? 'desc "' + description + '"' : "#desc 'Description of data_migration'" %>

  task <%= name.underscore %>: :environment do
    #TODO: data_migration code
  end
end