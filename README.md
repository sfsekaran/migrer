# Migrer
#### The polite data migration valet.

### What's with the name?

Migrer (me-gray) is French for migrate. My wife suggested the name, and it was much
less obnoxious than `morphin_time` or  `flying_v`, say. - @sfsekaran

## What is it?

Migrer creates migration-like tasks for running application scripts. It is primarily useful for updating database
records or running one-time tasks against separate environments.

**What is the difference between this and ActiveRecord migrations?**

Migrations should always be stable and are primarily for altering the structure of a database. Migrer is intended for
data migrations, or manipulating the data within that structure. Such tasks can become error-prone since they depend on
the state of models in the codebase, and are best not included in ActiveRecord migrations.

**Why not just create a regular rake task or use a script runner?**

Although Migrer data migrations can be run multiple times, they are primarily suited for one-time tasks (and often for
tasks that are not intended to be run more than once). Migrer not only creates a structure for these one-time tasks,
but also keeps track of which data migrations have already been processed. This is especially useful when managing
such tasks among multiple environments.

## Installation

Add this line to your application's Gemfile:

    gem 'migrer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install migrer

And install database migrations like so:

    $ bundle exec rake railties:install:migrations FROM=migrer
    $ bundle exec rake db:migrate

## Usage

### 1) Create the data migration

Create a data migration:

    $ bundle exec rails generate data_migration MyFirstDataMigration "optional description"

This will create the file:  lib/tasks/data_migrations/&lt;timestamp&gt;_my_first_data_migration.rb

Open this file and replace "TODO" with your data migration code!

### 2) Run a task

Unless you have the RAILS_ENV environment variable already set, prepend this to all of the following commands (replace
&lt;environment&gt; with the correct Rails environment (development, staging, production, etc.):

    RAILS_ENV=<environment>

All the following commands will ask for confirmation before executing.

**Run all unprocessed data migrations:**

    bundle exec rake data:migrate

**Run a single data migration (&lt;version&gt; is the timestamp at the beginning of the data migration file, just like
ActiveRecord migrations):**

    bundle exec rake data:migration VERSION=<version>

**Mark all data migrations as already processed:**

    bundle exec rake data:mark_all

**Mark a single data migration as already processed:**

    bundle exec rake data:mark VERSION=<version>

**Mark all data migrations as unprocessed (so they are included again when running data:migrate):**

    bundle exec rake data:unmark_all

**Mark a single data migration as unprocessed:**

    bundle exec rake data:unmark VERSION=<version>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* *Sathya Sekaran* ([sfsekaran](https://github.com/sfsekaran))
* *Michael Durnhofer* ([mdurn](https://github.com/mdurn))
