# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Specs
    class InstallGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      
      source_root File.expand_path('templates', __dir__)

      desc "Install the dependencies required for spec generators."

      def start
        # ensure_not_installed!
        install
        # bundle
      rescue StandardError => e
        exception 'Plutonium specs installation failed:', e
      end
      
      private

      # def ensure_not_installed!
      #   return unless File.exist? '.pu-version'

      #   error "Plutonium has already been installed" 
      # end
      
      def install
        add_gem "factory_bot-awesome_linter"
        copy_file "lib/tasks/factory_bot.rake", "lib/tasks/factory_bot.rake"
        write_config :specs, version: PlutoniumGenerators::VERSION, installed: true
      end

      def bundle
        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

      def add_gem(gem, group=nil)
        Bundler.with_unbundled_env do
          group = group == nil ? "" : "--group #{group}"
          run "bundle add #{gem} #{group}"
        end
      end
    end
  end
end
