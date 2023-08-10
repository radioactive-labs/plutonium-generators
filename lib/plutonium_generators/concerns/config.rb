# frozen_string_literal: true

require 'yaml'

module PlutoniumGenerators
  module Concerns
    module Config
      def write_config(scope, **kwargs)
        write_config! config.merge({scope => kwargs})
      end

      private

      def config
        @config ||= begin
          if File.exist? config_file
            YAML.load_file(config_file)
          else
            {}
          end
        end
      end

      def write_config! config
        File.write(config_file, YAML.dump(config))
        @config = config
      end

      def config_file
        '.pu'
      end
    end
  end
end
