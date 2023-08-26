# frozen_string_literal: true

require_relative 'time_helpers'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot::SyntaxRunner.include TimeHelpers
