# frozen_string_literal: true

require 'semantic_range'

module PlutoniumGenerators
  module Concerns
    module Installer
      protected

      def install!(scope)
        from = read_config(scope, :version, default: '0.1.0')
        versions = methods.map { |m| m.to_s.match(/install_v([\d_]+)/)&.[](1)&.gsub('_', '.') }.compact.sort
        versions.each do |version|
          next unless SemanticRange.satisfies?(version, ">=#{from}")

          send "install_v#{version.gsub('.', '_')}!".to_sym
        end

        write_config scope, version: PlutoniumGenerators::VERSION
        bundle!
      end

      def bundle!
        Bundler.with_unbundled_env do
          run 'bundle install'
        end
      end

      def add_gem(gem, group = nil)
        Bundler.with_unbundled_env do
          group = group.nil? ? '' : "--group #{group}"
          run "bundle add #{gem} #{group}"
        end
      end
    end
  end
end
