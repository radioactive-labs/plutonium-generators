# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Base
    class PkgGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Create a plutonium package"

      argument :name
      class_option :app, type: :boolean, desc: "Create the package as an app"

      def start
        template "lib/engine.rb", "packages/#{package_path}/lib/engine.rb"
        template "config/routes.rb", "packages/#{package_path}/config/routes.rb"
        create_file "packages/#{package_path}/app/controllers/#{package_path}/.keep"
        create_file "packages/#{package_path}/app/views/#{package_path}/.keep"
        create_file "packages/#{package_path}/app/models/#{package_path}/.keep" unless options[:app]

        insert_into_file "config/packages.rb",
          "require_relative \"../packages/#{package_path}/lib/engine\"\n"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def package_name
        suffix = options[:app] ? "_app" : ""
        package_name = name.underscore + suffix
        package_name.classify
      end

      def package_path
        package_name.underscore
      end

      def package_type
        options[:app] ? "App" : "Package"
      end
    end
  end
end
