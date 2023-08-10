# frozen_string_literal: true

module PlutoniumGenerators
  module Graphql
    module Types
      class Scalar < Base
        def to_graphql(_depth)
          ''
        end
      end
    end
  end
end
