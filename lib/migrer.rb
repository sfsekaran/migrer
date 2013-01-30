require "migrer/version"

module Migrer
  def self.table_name_prefix
    ''
  end
end

# Require our engine
require "migrer/engine"
