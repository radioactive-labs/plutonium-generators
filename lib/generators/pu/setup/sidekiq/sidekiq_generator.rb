# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class SidekiqGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup sidekiq'

      def start
        install! :sidekiq
      end

      protected

      def install_v0_1_0!
        add_gem 'sidekiq'
        add_gem 'sidekiq-failures'

        [
          'config/sidekiq.yml',
          'config/initializers/sidekiq.rb',
          'app/sidekiq/sidekiq_job.rb'
        ].each do |file|
          after_bundle :copy_file, file
        end

        proc_file 'sidekiq: bundle exec sidekiq -C config/sidekiq.yml'
        after_bundle :environment, 'config.active_job.queue_adapter = :sidekiq'

        pug 'setup:rspec_sidekiq' if pug_installed? :rspec
      end
    end
  end
end
