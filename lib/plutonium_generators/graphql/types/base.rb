# frozen_string_literal: true

module PlutoniumGenerators
  module Graphql
    module Types
      class Base
        attr_reader :context, :type_hash

        class << self
          def resolve(context, type_hash, depth = 0)
            return if depth > 3

            if type_hash[:type].present?
              resolve context, type_hash[:type], depth
            else
              case type_hash[:kind]
              when 'OBJECT'
                obj = Object.new context, context[:type_schema][type_hash[:name]]
                obj.send :resolve_dependencies, depth + 1
                obj
              when 'SCALAR'
                Scalar.new context, type_hash
              when 'NON_NULL', 'LIST'
                resolve context, type_hash[:ofType], depth
              when nil
                nil
              else
                # pp '~~~~~~~~~~'
                # ap type_hash[:kind]
                # pp '~~~~~~~~~~'
                nil
              end
            end
          end

          # def to_s
          #   repr.to_str
          # end

          def to_str
            repr.to_str
          end
        end

        def initialize(context, type_hash)
          @context = context
          @type_hash = type_hash
        end

        def repr
          @repr ||= {
            name: name,
            type_hash: type_hash
          }
        end

        def name
          type_hash[:name]
        end

        def to_json(state = nil)
          repr.to_json state
        end

        def as_json(state = nil)
          repr.as_json state
        end

        private

        def indent(str, depth)
          ((' ' * 2) * (depth + 1)) + str
        end
      end
    end
  end
end
