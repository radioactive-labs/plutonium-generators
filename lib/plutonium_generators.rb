# frozen_string_literal: true

require File.join(__dir__, 'plutonium_generators/version')
require File.join(__dir__, 'plutonium_generators/generator')
require File.join(__dir__, 'plutonium_generators/graphql/parser')

module PlutoniumGenerators
  class Error < StandardError; end
end
