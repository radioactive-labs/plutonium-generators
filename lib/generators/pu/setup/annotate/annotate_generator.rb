# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class AnnotateGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup annotate"

      def start
        install! :annotate
      end

      protected

      def install_v0_1_0!
        add_gem "annotate", group: :development

        after_bundle :generate, "annotate:install --force"
        {
          exclude_tests: true,
          exclude_fixtures: true,
          exclude_factories: true
        }.each do |opt, val|
          after_bundle :gsub_file, "lib/tasks/auto_annotate_models.rake", /.*'#{opt}.*/,
            indent("'#{opt}' => '#{val}',", 6)
        end
      end
    end
  end
end
