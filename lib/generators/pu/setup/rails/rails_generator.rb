# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class RailsGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup Rails'

      def start
        install! :rails
      end

      protected

      def install_v0_1_0!
        duplicate_file 'config/environments/production.rb', 'config/environments/staging.rb'

        proc_file 'web: bundle exec rails server -p $PORT'

        pug 'setup:dev'

        pug 'setup:pg'
        pug 'setup:redis'
        pug 'setup:sidekiq'

        pug 'setup:seeds'

        # Let's be honest. No one really uses this.
        # If you need this, add it back.
        remove_gem 'jbuilder'
      end
    end
  end
end
