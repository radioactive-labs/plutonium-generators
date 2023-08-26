# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class RspecGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup Rspec'

      def start
        install! :rspec
      end

      protected

      def install_v0_1_0!
        rails
        faker
        webmock
        shoulda_matchers
        database_cleaner

        pug 'setup:factory_bot'
        pug 'setup:rspec_sidekiq' if pug_installed? :sidekiq

        misc
      end

      private

      def rails
        add_gem 'rspec-rails', group: %i[development test]
        after_bundle :generate,
                     'rspec:install --force'
        after_bundle :gsub_file, 'spec/spec_helper.rb', /^=begin$|^=end\n/, ''
        after_bundle :run, 'bundle binstubs rspec-core'
      end

      def faker
        add_gem 'faker', group: %i[development test]
        after_bundle :insert_into_file, 'spec/rails_helper.rb', indent("Faker::Config.locale = 'en-US'\n\n", 2),
                     after: "RSpec.configure do |config|\n"
      end

      def webmock
        add_gem 'webmock', group: :test
        after_bundle :insert_into_file, 'spec/rails_helper.rb', "\nrequire webmock/rspec\n",
                     after: /# Add additional requires below this line.*\n/
        after_bundle :insert_into_file, 'spec/rails_helper.rb', "WebMock.disable_net_connect!\n",
                     after: "require webmock/rspec\n"
      end

      def shoulda_matchers
        add_gem 'shoulda-matchers', group: :test
        after_bundle :copy_file, 'spec/support/shoulda_matchers.rb'
      end

      def database_cleaner
        add_gem 'database_cleaner-active_record', group: :test
        after_bundle :copy_file, 'spec/support/database_cleaner.rb', force: true

        after_bundle :gsub_file, 'spec/rails_helper.rb', /^  config.fixture_path/, '  # config.fixture_path'
        after_bundle :gsub_file, 'spec/rails_helper.rb',
                     /^  config.use_transactional_fixtures = true/,
                     '  config.use_transactional_fixtures = false'
      end

      def misc
        rubocop :rspec
        after_bundle :copy_file, 'spec/support/time_helpers.rb', force: true
      end
    end
  end
end
