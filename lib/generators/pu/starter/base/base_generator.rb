# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

return unless PlutoniumGenerators.rails?

module Pu
  module Starter
    class BaseGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Set up the base requirements for Plutonium"

      def start
        invoke "pu:base:core"
      rescue => e
        exception "#{self.class} failed:", e
      end
    end
  end
end
