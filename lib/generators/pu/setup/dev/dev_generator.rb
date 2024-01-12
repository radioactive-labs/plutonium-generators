# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class DevGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup nice to have development config"

      def start
        set_ruby_version!

        install! :dev
      end

      protected

      def install_v0_1_0!
        # Enable query logging in dev and in console
        [
          "config/initializers/console.rb"
        ].each do |file|
          copy_file file, file
        end
        environment "# Enable query logging\nActiveRecord::Base.logger = Logger.new($stdout)", env: :development

        # web_proc =
        #   "unset PORT && env RUBY_DEBUG_OPEN=true ./wait-for-it.sh -t 0 localhost:5432 " \
        #   "-- ./wait-for-it.sh -t 0 localhost:6379 -- rails server"

        web_proc = "unset PORT && env RUBY_DEBUG_OPEN=true rails server"
        proc_file :web, web_proc, env: :dev
        proc_file "docker-compose", "docker compose up", env: :dev

        # copy_file "wait-for-it.sh"
        # in_root do
        #   run "chmod +x wait-for-it.sh"
        # end

        gitignore ".DS_Store"
        add_gem "awesome_print", group: :development

        # pug "setup:rubocop"
        pug "setup:rspec"
        pug "setup:mail_catcher"
        pug "setup:annotate"
        pug "setup:vscode" if pug_installed?(:vscode) || yes?("Setup VS Code?")
      end
    end
  end
end
