# frozen_string_literal: true

require File.join(__dir__, 'concerns/config.rb')
require File.join(__dir__, 'concerns/logger.rb')
require File.join(__dir__, 'concerns/serializer.rb')
require File.join(__dir__, 'concerns/actions.rb')

module PlutoniumGenerators
  module Generator
    include Concerns::Config
    include Concerns::Logger
    include Concerns::Serializer
    include Concerns::Actions

    def self.included(base)
      base.send :class_option, :interactive, type: :boolean, desc: 'Show prompts. Default: true'
      base.send :class_option, :bundle, type: :boolean, desc: 'Run bundle after setup. Default: true'
      base.send :class_option, :lint, type: :boolean, desc: 'Run linter after generation. Default: false'
    end

    def rails?
      PlutoniumGenerators.rails?
    end

    def appname
      rails? ? Rails.application.class.module_parent.name : 'PlutoniumGenerators'
    end

    def app_name
      appname.underscore
    end
  end
end
