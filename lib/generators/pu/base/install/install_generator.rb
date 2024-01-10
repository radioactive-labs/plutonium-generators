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

        invoke "pu:base:core"
        invoke "pu:gem:simple_form"
        invoke "pu:gem:pagy"
        invoke "pu:gem:rabl"

        copy_file "lib/templates/active_record/model/model.rb.tt"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def setup_packaging_system
        create_file "config/packages.rb", skip: true
        insert_into_file "config/application.rb", "\nrequire_relative \"packages\"\n", after: /Bundler\.require.*\n/

        # Ensures app packages are booted after normal packages
        config = "config.railties_order += Rails::Engine.descendants.select { |engine| engine.include? Plutonium::App }"
        environment config
      end
    end
  end
end
