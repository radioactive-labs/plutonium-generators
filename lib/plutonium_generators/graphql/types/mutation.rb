# frozen_string_literal: true

module PlutoniumGenerators
  module Graphql
    module Types
      class Mutation < Object
        def repr
          @repr ||= super.merge({
                                  args: @args
                                })
        end
      end
    end
  end
end
