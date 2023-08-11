# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Workspace
    class VscodeGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path('templates', __dir__)

      desc 'Setup VS Code workspace.'

      def start
        install! :workspace_vscode
      rescue StandardError => e
        exception 'Plutonium vscode workspace setup failed:', e
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

        set_ruby_version!
        add_gem 'solargraph', group: :development
        add_gem 'htmlbeautifier', group: :development
      end
    end
  end
end
