# frozen_string_literal: true

module PlutoniumGenerators
  module Graphql
    module Types
      class Object < Base
        attr_reader :fields

        def repr
          @repr ||= super.merge({
            fields: fields&.transform_values(&:repr)
          })
        end

        def to_graphql(depth)
          return if fields.empty?

          str = ""
          fields.each do |k, v|
            result = v.to_graphql(depth + 1)
            result = case v
            when Object
              " {\n#{result} #{indent("}", depth)}"
            else
              result
            end

            next if result.gsub(/\s/, "") == "{}"

            str += indent(k, depth)
            str += result
            str += "\n"
          end
          str
        end

        private

        def resolve_dependencies(depth)
          @fields ||= begin
            fields = {}
            type_hash&.dig(:fields)&.each do |f|
              fields[f[:name]] = Base.resolve(context, f, depth)
            end
            fields.compact.with_indifferent_access
          end
        end
      end
    end
  end
end
