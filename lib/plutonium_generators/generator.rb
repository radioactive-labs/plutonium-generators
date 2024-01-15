# frozen_string_literal: true

require "semantic_range"
require "tty-prompt"

require File.join(__dir__, "concerns/config.rb")
require File.join(__dir__, "concerns/logger.rb")
require File.join(__dir__, "concerns/serializer.rb")
require File.join(__dir__, "concerns/actions.rb")

module PlutoniumGenerators
  module Generator
    include Concerns::Config
    include Concerns::Logger
    include Concerns::Serializer
    include Concerns::Actions

    def self.included(base)
      base.send :class_option, :interactive, type: :boolean, desc: "Show prompts. Default: true"
      base.send :class_option, :bundle, type: :boolean, desc: "Run bundle after setup. Default: true"
      base.send :class_option, :lint, type: :boolean, desc: "Run linter after generation. Default: false"
    end

    protected

    def reserved_packages
      %w[core reactor app main]
    end

    def validate_package_name(package_name)
      error("Package name is reserved\n\n#{reserved_packages.join "\n"}") if reserved_packages.include?(package_name)
    end

    def available_packages
      @available_packages ||= begin
        packages = ["main_app"] + Dir["packages/*"].map { |dir| dir.gsub "packages/", "" }
        packages - reserved_packages
      end
    end

    def select_package(selected_package = nil)
      if available_packages.include?(selected_package)
        selected_package
      else
        prompt.select("Select package", available_packages)
      end
    end

    def select_destination_package
      @destination_package = select_package destination_package

      self.destination_root = destination_main_app? ? nil : "packages/#{destination_package}"
      destination_package
    end

    def destination_main_app?
      destination_package == "main_app"
    end

    def destination_package
      @destination_package || options[:package]
    end

    # ####################

    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def rails?
      PlutoniumGenerators.rails?
    end

    def appname
      rails? ? Rails.application.class.module_parent.name : "PlutoniumGenerators"
    end

    def app_name
      appname.underscore
    end

    def pug_installed?(feature, version: nil)
      installed_version = read_config(:installed, feature)
      return false unless installed_version.present?

      version.present? ? SemanticRange.satisfies?(installed_version, ">=#{version}") : true
    end
  end
end
