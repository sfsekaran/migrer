class CreateMigrerTable < ActiveRecord::Migration
  def change
    create_table :data_migration_versions do |t|
      t.string :version
      t.timestamps
    end
  end
end
