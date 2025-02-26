require "money-rails"
require_relative "priced/version"
require_relative "priced/engine"

module Priced
  mattr_accessor :model_parent_class, default: "ApplicationRecord"
  mattr_accessor :default_duration_unit, default: :days
  mattr_accessor :default_duration_value, default: 1

  autoload :Query, "priced/query"

  module Adapters
    autoload :Base, "priced/adapters/base"
    autoload :PostgreSQL, "priced/adapters/postgresql"
    autoload :SQLite, "priced/adapters/sqlite"
    autoload :MySQL, "priced/adapters/mysql"
  end
end
