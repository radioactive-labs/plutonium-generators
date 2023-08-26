# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class VscodeGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup VS Code'

      def start
        install! :vscode
      end

      protected

      def install_v0_1_0!
        [
          '.vscode/extensions.json',
          '.vscode/launch.json',
          '.vscode/settings.json'
        ].each do |file|
          copy_file file, file
        end

        # Required for the extensions
        add_gem 'solargraph', group: :development
        add_gem 'htmlbeautifier', group: :development
      end
    end
  end
end
