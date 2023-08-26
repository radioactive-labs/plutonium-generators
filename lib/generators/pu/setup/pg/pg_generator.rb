# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class PgGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup postgres'

      def start
        install! :pg
      end

      protected

      def install_v0_1_0!
        docker_compose :pg
        gitignore '.data/'

        add_gem 'pg'
        copy_file 'db/initdb.d/create-multiple-postgresql-databases.sh', force: true
        after_bundle :template, 'config/database.yml.tt', force: true

        # No longer need this since we are using postgres
        remove_gem 'sqlite3'
      end
    end
  end
end
