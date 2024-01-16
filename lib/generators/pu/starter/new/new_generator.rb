# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

return if PlutoniumGenerators.rails?

require "open3"
module Pu
  module Starter
    class NewGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Create a new plutonium starter project"

      argument :name

      def start
        install_required_rails_version
        create_starter_project

        invoke "pu:rodauth:install", []
        invoke "pu:rodauth:account", ["admin"]
      rescue => e
        exception "#{self.class} failed:", e
      end

      protected

      def install_required_rails_version
        Bundler.unbundled_system "gem install rails -v #{rails_version}"
      end

      def create_starter_project
        cmd = "rails _#{rails_version}_ new #{project_dir} --name=#{name} " \
              " --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-jbuilder" \
              " --skip-test --skip-system-test" \
              " --javascript=esbuild --css=bootstrap" \
              " -m #{rails_template_path}"
        Bundler.unbundled_system cmd
      end

      def rails_version
        PlutoniumGenerators::RAILS_VERSION
      end

      def project_dir
        "/Users/stefan/code/plutonium/starters/#{name}/"
      end

      def rails_template_path
        File.expand_path("starter_rails_template.rb", __dir__)
      end
    end
  end
end
