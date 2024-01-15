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
          select_destination_package
          @name = [destination_main_app? ? nil : destination_package, super.underscore].compact.join "/"
        end
      end

      def package_name
        destination_package.classify
      end
    end
  end
end
