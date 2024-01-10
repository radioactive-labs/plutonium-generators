# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Gem
    class RablGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Install Rabl"

      def start
        Bundler.with_unbundled_env do
          run "bundle add rabl"
        end

        directory "config"
      rescue => e
        exception "#{self.class} failed:", e
      end
    end
  end
end
