# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Base
    class CoreGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Generate the core pkg"

      def start
        invoke "pu:base:pkg", ["core"]
        directory "app", "packages/core/app"
      rescue => e
        exception "#{self.class} failed:", e
      end
    end
  end
end
