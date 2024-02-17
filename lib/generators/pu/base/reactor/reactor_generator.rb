# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Base
    class ReactorGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Creates the reactor package"

      def start
        template "lib/engine.rb", "packages/#{package_namespace}/lib/engine.rb"
        directory "app", "packages/#{package_namespace}/app"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private

      def package_name
        "Reactor"
      end

      def package_namespace
        package_name.underscore
      end

      def package_type
        "Reactor::Engine"
      end
    end
  end
end
