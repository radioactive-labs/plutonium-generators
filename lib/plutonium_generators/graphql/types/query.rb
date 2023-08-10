# frozen_string_literal: true

module PlutoniumGenerators
  module Graphql
    module Types
      class Query < Object
        attr_reader :type

        def repr
          @repr ||= super.merge({
                                  type: type&.repr
                                }).except :fields
        end

        def to_graphql(depth)
          str = indent "#{name} {\n", depth
          str += type.to_graphql(depth + 1)
          str + indent('}', depth)
        end

        def resolver
          context[:query_class].fields[name].resolver
        end

        private

        def resolve_dependencies(depth)
          @type ||= Base.resolve(context, type_hash&.dig(:type), depth)
        end
      end
    end
  end
end
