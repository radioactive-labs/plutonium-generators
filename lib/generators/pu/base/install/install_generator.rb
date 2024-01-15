# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

return unless PlutoniumGenerators.rails?

module Pu
  module Base
    class InstallGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Set up the base requirements for Plutonium"

      def start
        gem "plutonium", path: "/Users/stefan/code/plutonium/starters/plutonium/"

        setup_packaging_system
        install_required_gems
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def setup_packaging_system
        create_file "config/packages.rb", skip: true
        insert_into_file "config/application.rb", "\nrequire_relative \"packages\"\n", after: /Bundler\.require.*\n/
        insert_into_file "config/application.rb", indent("Plutonium.configure_rails config\n\n", 4), after: /.*< Rails::Application\n/
      end

      def install_required_gems
        invoke "pu:base:reactor"
        invoke "pu:gem:simple_form"
        invoke "pu:gem:pagy"
        invoke "pu:gem:rabl"
      end
    end
  end
end