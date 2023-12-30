# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class RubocopGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup rubocop"
      class_option :rails, type: :boolean, default: true, desc: "Setup rubocop for Rails"

      def start
        install! :rubocop
      end

      protected

      def install_v0_1_0!
        rubocop :performance

        return unless options[:rails]

        rubocop :rails
        rubocop :capybara
      end
    end
  end
end
