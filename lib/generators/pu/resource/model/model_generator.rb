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
          @selected_feature = select_feature selected_feature
          @name = [main_app? ? nil : feature_package_name, super.underscore].compact.join "/"
        end
      end

      def feature_package_name
        main_app? ? nil : selected_feature.classify
      end

      def main_app?
        selected_feature == "main_app"
      end

      def selected_feature
        @selected_feature || options[:feature]
      end
    end
  end
end
