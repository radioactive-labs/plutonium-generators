# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

return unless PlutoniumGenerators.rails?

module Pu
  module Specs
    class AllGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      attr_reader :schema_class

      # class_option :graphql_schema, type: :string, default: nil
      # class_option :graphql_queries, type: :boolean, default: false
      class_option :models, type: :boolean, default: true

      desc "Runs spec generators for the entire project\n\n" \
           "Models:\n" \
           "Generates specs and factories for all models that inherit ApplicationRecord\n\n"

      def start
        # generate_query_specs if options[:graphql_queries]
        generate_model_specs if options[:models]
        lint_models if options[:models]
      rescue StandardError => e
        exception 'Specs generation failed:', e
      end

      private

      def lint_models
        if lint?
          info 'Running factory_bot:lint'
          rake 'factory_bot:lint'
        else
          info(
            "Run `rails factory_bot:lint` to validate your generated factories.\n" \
            'Visit https://thoughtbot.github.io/factory_bot/linting-factories/summary.html for more information'
          )
        end
      end

      def validate_schema
        @schema_class = PlutoniumGenerators::Graphql::Parser.parse options[:graphql_schema].classify.constantize
      end

      def generate_query_specs
        validate_schema
        schema_class[:queries].each_key do |query|
          generate "specs:query #{query}"
        end
      end

      def generate_model_specs
        Rails.application.eager_load! unless Rails.application.config.eager_load

        ApplicationRecord.descendants.each do |model|
          generate "pu:specs:model #{model} --no-lint --no-interactive --no-bundle"
        end

        success 'Model spec generation compeleted'
      end
    end
  end
end
