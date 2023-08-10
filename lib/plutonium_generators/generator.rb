# frozen_string_literal: true

require File.join(__dir__, 'concerns/config.rb')
require File.join(__dir__, 'concerns/logger.rb')
require File.join(__dir__, 'concerns/serializer.rb')

module PlutoniumGenerators
  module Generator
    include Concerns::Config
    include Concerns::Logger
    include Concerns::Serializer
  end
end
