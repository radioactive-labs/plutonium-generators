# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

require "rails/generators"
require "rails/generators/active_record/model/model_generator"

module Pu
  module Resource
    class ModelGenerator < ActiveRecord::Generators::ModelGenerator
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)
      remove_hook_for :test_framework

      class_option :package, type: :string

      def create_controller
        template "controller.rb", File.join("app/controllers", class_path, "#{file_name.pluralize}_controller.rb")
      end

      def create_policy
        template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
      end

      def create_presenter
        template "presenter.rb", File.join("app/presenters", class_path, "#{file_name}_presenter.rb")
      end

      private

      def name
        @pu_name ||= begin
          select_package
          [main_app? ? nil : package, super.underscore].compact.join "/"
        end
      end

      def select_package
        packages = ["main_app"] + Dir["packages/*"].map { |dir| dir.gsub "packages/", "" }
        unless packages.include?(package)
          @package = ask("Select package", default: "main_app", limited_to: packages)
        end

        self.destination_root = "packages/#{package}" unless main_app?
      end

      def main_app?
        package == "main_app"
      end

      def package
        @package || options[:package]
      end
    end
  end
end
