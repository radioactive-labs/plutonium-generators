# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class RedisGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup Redis'

      def start
        install! :redis
      end

      protected

      def install_v0_1_0!
        docker_compose :redis
        add_gem 'redis'
        after_bundle :environment, 'config.cache_store = :redis_cache_store', env: %i[production staging]
      end
    end
  end
end
