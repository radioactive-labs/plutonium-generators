# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Gem
    class PagyGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Install Pagy"

      def start
        Bundler.with_unbundled_env do
          run "bundle add pagy"
        end

        generate "simple_form:install", []
        directory "config"
      rescue => e
        exception "#{self.class} failed:", e
      end
    end
  end
end
