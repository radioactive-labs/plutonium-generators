# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Specs
    class InstallGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path('templates', __dir__)

      desc 'Install the dependencies required for spec generators.'

      def start
        install! :specs
      rescue StandardError => e
        exception 'Plutonium specs installation failed:', e
      end

      protected

      def install_v0_1_0!
        add_gem 'factory_bot-awesome_linter', group: :development
        copy_file 'lib/tasks/factory_bot.rake', 'lib/tasks/factory_bot.rake'
      end
    end
  end
end
