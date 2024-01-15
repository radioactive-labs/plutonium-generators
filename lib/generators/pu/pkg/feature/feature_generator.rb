# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Pkg
    class FeatureGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Create a plutonium feature package"

      argument :name

      def start
        validate_package_name package_name

        template "lib/engine.rb", "packages/#{package_namespace}/lib/engine.rb"
        create_file "packages/#{package_namespace}/app/controllers/#{package_namespace}/.keep"
        create_file "packages/#{package_namespace}/app/views/#{package_namespace}/.keep"
        create_file "packages/#{name.underscore}/app/models/#{package_namespace}/.keep"

        insert_into_file "config/packages.rb", "require_relative \"../packages/#{package_namespace}/lib/engine\"\n"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def package_name
        name.classify
      end

      def package_namespace
        package_name.underscore
      end

      def package_type
        "Feature"
      end
    end
  end
end
