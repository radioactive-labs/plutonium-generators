# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Specs
    class QueryGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path('templates', __dir__)

      InvalidQueryError = Class.new(StandardError)

      argument :name
      class_option :schema, type: :string, default: 'AppApiSchema'

      def start
        validate_schema
        validate_resolver

        generate_spec
      rescue StandardError => e
        exception 'Query generation failed:', e
      end

      private

      def query_name
        name
      end

      def resolver_name
        @query.resolver || "'#{@schema[:query_class]}.#{@query.name}'"
      end

      def validate_schema
        @schema = PlutoniumGenerators::Graphql::Parser.parse options[:schema].classify.constantize
      end

      def validate_resolver
        @query = @schema[:queries][query_name]
        raise InvalidQueryError, "Invalid query: #{query_name}" unless @query.present?
      end

      def generate_spec
        spec_template = 'query_spec.erb'
        spec_path = "spec/queries/#{query_name.underscore}_spec.rb"

        template(spec_template, spec_path, force: true)
      end
    end
  end
end
