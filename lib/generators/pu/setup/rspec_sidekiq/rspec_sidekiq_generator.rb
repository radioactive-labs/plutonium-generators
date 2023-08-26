# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)

module Pu
  module Setup
    class RspecSidekiqGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc 'Setup rspec-sidekiq'

      def start
        install! :rspec_sidekiq
      end

      protected

      def install_v0_1_0!
        add_gem 'rspec-sidekiq', group: :test

        [
          'spec/support/sidekiq.rb'
        ].each do |file|
          after_bundle :copy_file, file
        end
      end
    end
  end
end
