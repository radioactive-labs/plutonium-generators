# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Base
    class ReactorGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Creates the reactor package"

      def start
        template "lib/engine.rb", "packages/reactor/lib/engine.rb"
        insert_into_file "config/packages.rb", "require_relative \"../packages/reactor/lib/engine\"\n"
        directory "app", "packages/reactor/app"
      rescue => e
        exception "#{self.class} failed:", e
      end

      private
    end
  end
end
