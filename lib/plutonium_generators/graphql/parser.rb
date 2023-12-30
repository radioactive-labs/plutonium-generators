# frozen_string_literal: true

require File.join(__dir__, "types/base.rb")
require File.join(__dir__, "types/object.rb")
require File.join(__dir__, "types/mutation.rb")
require File.join(__dir__, "types/query.rb")
require File.join(__dir__, "types/scalar.rb")

module PlutoniumGenerators
  module Graphql
    # rubocop:disable Metrics/AbcSize
    class Parser
      class << self
        def parse(schema_class)
          raise ArgumentError, "Expects a instance of GraphQL::Schema" unless schema_class < GraphQL::Schema

          @cache ||= {}
          build_schema(schema_class)
        end

        private

        def build_schema(schema_class)
          schema = schema_class.as_json
          context = {
            schema_class:,
            schema: schema_class,
            type_schema: {},
            query_name: schema["data"]["__schema"]["queryType"]&.dig("name"),
            mutation_name: schema["data"]["__schema"]["mutationType"]&.dig("name"),
            subscription_name: schema["data"]["__schema"]["subscriptionType"]&.dig("name"),
            queries: {},
            mutations: {},
            subscriptions: {},
            types: {}
          }.with_indifferent_access

          build_types context
          build_query context
          # build_mutation context
          # build_subscription context

          File.write "schema.json", JSON.pretty_generate(context[:schema])
          context
        end

        def build_types(context)
          exemptions = [context[:query_name], context[:mutation_name], context[:subscription_name]]

          types = context[:schema]["data"]["__schema"]["types"].reject do |t|
            t["kind"] == "OBJECT" && exemptions.include?(t["name"])
          end
          types.each { |t| context[:type_schema][t["name"]] = t }
          context[:type_schema].each_value { |t| context[:types][t["name"]] = Types::Base.resolve(context, t) }
          context[:types].compact!
        end

        def build_query(context)
          return unless context[:query_name].present?

          context[:query_class] = context[:schema_class].query
          context[:query_hash] = context[:schema]["data"]["__schema"]["types"].detect do |t|
            t["kind"] == "OBJECT" && t["name"] == context[:query_name]
          end
          context[:query_hash]["fields"].each do |q|
            query = Types::Query.new(context, q)
            query.send :resolve_dependencies, 0
            context[:queries][q["name"]] = query
          end
        end

        def build_mutation(context)
          return unless context[:mutation_name].present?

          context[:mutation_class] = context[:schema_class].mutation
          context[:mutation_hash] = context[:schema]["data"]["__schema"]["types"].detect do |t|
            t["kind"] == "OBJECT" && t["name"] == context[:mutation_name]
          end
          context[:mutation_hash]["fields"].each do |m|
            mutation = Types::Mutation.new(context, m)
            context[:mutations][m["name"]] = mutation
            mutation.send :resolve_dependencies, 0
          end
        end

        def build_subscription(context)
          # We currently don't support subscriptions
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
