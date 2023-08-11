# frozen_string_literal: true

require 'semantic_range'

module PlutoniumGenerators
  module Concerns
    module Installer
      protected

      def install!(scope)
        from_version = read_config(scope, :version, default: '0.0.0')
        info "Installing #{scope} from v#{from_version}"

        versions = methods.map { |m| m.to_s.match(/install_v([\d_]+)/)&.[](1)&.gsub('_', '.') }.compact.sort
        versions.each do |version|
          next unless SemanticRange.satisfies?(version, ">#{from_version}")

          info "Installing #{scope} v#{version}"
          send "install_v#{version.gsub('.', '_')}!".to_sym
        end

        bundle!

        write_config scope, version: PlutoniumGenerators::VERSION
      end

      def bundle!
        info 'Bundle'
        Bundler.with_unbundled_env do
          run 'bundle install'
        end
      end

      def set_ruby_version!
        info "Setting ruby version to #{PlutoniumGenerators::RUBY_VERSION}"
        create_file '.ruby-version', PlutoniumGenerators::RUBY_VERSION, force: true
        replace_in_file 'Gemfile', /^ruby ["']+.*["']+/, "ruby '~> #{PlutoniumGenerators::RUBY_VERSION}'"
      end

      def add_gem(gem, **kwargs)
        args = kwargs.map { |k, v| "--#{k} #{v}" }.join ' '

        info "Adding gem: #{gem} #{args}"
        Bundler.with_unbundled_env do
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
