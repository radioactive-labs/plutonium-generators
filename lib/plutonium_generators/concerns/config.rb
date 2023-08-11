# frozen_string_literal: true

require 'yaml'

module PlutoniumGenerators
  module Concerns
    module Config
      def write_config(scope, **kwargs)
        write_config! config.deep_merge({ scope => kwargs })
      end

      def read_config(scope, key, default: nil)
        config.dig(scope, key) || default
      end

      private

      def config
        @config ||= if File.exist? config_file
                      YAML.load_file(config_file)
                    else
                      {}
                    end
      end

      def write_config!(config)
        File.write(config_file, YAML.dump(config))
        @config = config
      end

      def config_file
        '.pu'
      end
    end
  end
end
