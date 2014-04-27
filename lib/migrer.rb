require "migrer/version"
require "migrer/configuration"

module Migrer
  class << self
    attr_writer :configuration
  end

  def self.table_name_prefix
    ''
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.paranoid?
    ENV['PARANOID'] == 'true' || configuration.paranoid
  end
end

# Require our engine
require "migrer/engine"
