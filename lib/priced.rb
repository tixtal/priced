require "money-rails"
require_relative "priced/version"
require_relative "priced/engine"

module Priced
  mattr_accessor :model_parent_class, default: "ApplicationRecord"
  mattr_accessor :weekend_days, default: [0, 6]

  autoload :Priceable, "priced/priceable"
end
