# frozen_string_literal: true

require 'semantic_range'

module PlutoniumGenerators
  module Concerns
    module Installer
      def ruby_version
        PlutoniumGenerators::RUBY_VERSION
      end

      def generator_version
        PlutoniumGenerators::VERSION
      end

      protected

      def install!(scope)
        from = read_config(scope, :version, default: '0.0.0')
        versions = methods.map { |m| m.to_s.match(/install_v([\d_]+)/)&.[](1)&.gsub('_', '.') }.compact.sort
        versions.each do |version|
          next unless SemanticRange.satisfies?(version, ">#{from}")

          info "Installing #{scope}:#{version}"
          send "install_v#{version.gsub('.', '_')}!".to_sym
        end

        write_config scope, version: generator_version
        # bundle!
      end

      def bundle!
        Bundler.with_unbundled_env do
          run 'bundle install'
        end
      end

      def add_gem(gem, **kwargs)
        Bundler.with_unbundled_env do
          args = kwargs.map { |k, v| "--#{k} #{v}" }.join ' '
          run "bundle add #{gem} #{args} --skip-install "
        end
      end

      def replace_in_file(filename, pattern, replacement)
        return unless File.exist? filename

        gemfile = File.read('Gemfile')
        File.write 'Gemfile', gemfile.gsub(pattern, replacement)
      end
    end
  end
end
