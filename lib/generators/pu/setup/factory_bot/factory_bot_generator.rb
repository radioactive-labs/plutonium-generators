# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class FactoryBotGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup rspec"
      class_option :copy_task, type: :boolean, default: false,
        desc: "Setup the factory_bot linter in your own application."

      def start
        install! :factory_bot
      end

      protected

      def install_v0_1_0!
        add_gem "factory_bot_rails", group: %i[development test]

        rubocop :factory_bot
        environment_generator "g.fixtures = false"
        after_bundle :copy_file, "spec/support/factory_bot.rb"

        return unless options[:copy_task]

        add_gem "factory_bot-awesome_linter", group: %i[development test]
        after_bundle :copy_file, "lib/tasks/factory_bot.rake"
      end
    end
  end
end
