require "rails/engine"

module Priced
  class Engine < ::Rails::Engine
    engine_name 'priced'

    initializer 'priced.load_priced' do
      ActiveSupport.on_load :active_record do
        def self.has_priced
          include Priced::Priceable
        end
      end
    end
  end
end