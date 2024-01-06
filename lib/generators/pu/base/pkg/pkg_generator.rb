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
        template "lib/engine.rb", "packages/#{package_namespace}/lib/engine.rb"
        create_file "packages/#{package_namespace}/app/controllers/#{package_namespace}/.keep"
        create_file "packages/#{package_namespace}/app/views/#{package_namespace}/.keep"

        if options[:app]
          template "config/routes.rb", "packages/#{package_namespace}/config/routes.rb"
        else
          create_file "packages/#{package_namespace}/app/models/#{package_namespace}/.keep"
        end

        insert_into_file "config/packages.rb", "require_relative \"../packages/#{package_namespace}/lib/engine\"\n"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def package_name
        suffix = options[:app] ? "_app" : ""
        package_name = name.underscore + suffix
        package_name.classify
      end

      def package_namespace
        package_name.underscore
      end

      def package_type
        options[:app] ? "App" : "Package"
      end
    end
  end
end
