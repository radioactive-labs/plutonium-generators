# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

return unless PlutoniumGenerators.rails?

module Pu
  module Base
    class SetupGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Base setup required for plutonium"

      def start
        setup_packages
        setup_boot_order
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def setup_packages
        create_file "config/packages.rb", skip: true
        insert_into_file "config/application.rb",
          "\nrequire_relative \"packages\"\n",
          after: /Bundler\.require.*\n/
      end

      def setup_boot_order
        config = "config.railties_order += Rails::Engine.descendants.select { |engine| engine.include? Plutonium::App }"
        environment config
      end
    end
  end
end
