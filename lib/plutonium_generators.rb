# frozen_string_literal: true

require File.expand_path("plutonium_generators/railtie", __dir__) if defined?(Rails::Railtie)

require File.expand_path("plutonium_generators/version", __dir__)
require File.expand_path("plutonium_generators/generator", __dir__)
require File.expand_path("plutonium_generators/installer", __dir__)
require File.expand_path("plutonium_generators/graphql/parser", __dir__)

module PlutoniumGenerators
  class Error < StandardError; end

  ROOT_DIR = File.expand_path("../", __dir__)

  class << self
    def rails?
      !!Rails.application
    rescue NoMethodError
      false
    end
  end
end
