# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class SeedsGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup database"

      def start
        install! :seeds
      end

      protected

      def install_v0_1_0!
        copy_file "db/seeds.rb", force: true

        pug "db:seed initial"
        pug "db:seed initial --env development"
      end
    end
  end
end
