# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'open3'
require 'fileutils'

module PlutoniumGenerators
  module Concerns
    module Actions
      protected

      def set_ruby_version!
        log :set_ruby_version!, PlutoniumGenerators::RUBY_VERSION

        in_root do
          create_file '.ruby-version', PlutoniumGenerators::RUBY_VERSION, force: true, verbose: false
          gsub_file 'Gemfile', /^ruby ["'].*["']/, "ruby '~> #{PlutoniumGenerators::RUBY_VERSION}'", verbose: false
        end
      end

      def gem(name, **kwargs)
        groups = Array(kwargs.delete(:group))

        in_root do
          begin
            # Create a temp gemfile
            File.rename('Gemfile', 'Gemfile.bak')
            File.write('Gemfile', '')
            # Generate the directive
            super
            # Get the generated directive
            directive = gemfile.strip
          ensure
            # Restore our gemfile
            File.delete 'Gemfile'
            File.rename 'Gemfile.bak', 'Gemfile'
          end

          pattern = /^# gem ['"]#{name}['"].*/
          if gemfile.match(pattern)
            # Replace commented out directive
            gsub_file('Gemfile', pattern, directive)
            break
          end

          # Remove existing directive
          remove_gem name

          # Insert the new directive
          if groups != []
            str = groups.sort.map(&:inspect).join(', ')
            after_sentinel = "group #{str} do\n"

            unless File.read('Gemfile').match?(/^#{after_sentinel}/)
              inject_into_file 'Gemfile', "\n#{after_sentinel}end\n"
            end
          else
            after_sentinel = "# Project gems\n\n"
            unless File.read('Gemfile').match?(/^#{after_sentinel}/)
              inject_into_file 'Gemfile', "\n#{after_sentinel}", after: /^ruby .*\n/
            end
          end

          inject_into_file 'Gemfile', "#{directive}\n", after: /^#{after_sentinel}/
        end
      end

      #
      # Removes a gem from the Gemfile
      # It also removes any preceeding comments.
      #
      # @param gem [String] the name of the gem to remove
      # @return [void]
      #
      def remove_gem(gem)
        log :remove_gem, gem
        gsub_file 'Gemfile', /(:?^.*#.*\n)*.*gem ['"]#{gem}['"].*\n/, '', verbose: false
      end

      def docker_compose(source)
        log :docker_compose, source

        in_root do
          compose_file = 'docker-compose.yml'
          compose_definition = YAML.load_file(compose_file) if File.exist?(compose_file)
          compose_definition ||= {
            version: '3.7',
            services: {}
          }
          compose_definition.deep_stringify_keys!

          new_definition = YAML.load template_in_mem("docker-compose/#{source}.yml.tt")
          compose_definition.deep_merge! new_definition.deep_stringify_keys

          create_file compose_file, YAML.dump(compose_definition), force: true
        end
      end

      def template_in_mem(source)
        source = File.binread File.expand_path(find_in_source_paths(source.to_s))
        ERB.new(source, trim_mode: '-').result(binding)
      end

      def duplicate_file(src, dest)
        log :duplicate_file, "#{src} -> #{dest}"

        in_root do
          FileUtils.cp src, dest
        rescue StandardError => e
          exception "An error occurred while copying the file '#{src}' to '#{dest}'", e
        end
      end

      def proc_file(command)
        log :proc_file, command

        in_root do
          File.write('Procfile', '') unless File.exist? 'Procfile'
          insert_into_file 'Procfile', "#{command}\n"
        end
      end

      def initializer_template(filename, template)
        log :initializer_template, filename

        initializer filename do
          template_in_mem template
        end
      end

      def environment(data = nil, options = {})
        data ||= yield if block_given?

        log :environment, data

        in_root do
          def replace_existing(file, data)
            gsub_file file, Regexp.new(".*#{data.split('=').first.strip}.*=.*\n"), data, verbose: false
          end

          if options[:env].nil?
            data = optimize_indentation(data, 4)
            file = 'config/application.rb'
            replace_existing file, data
            break if File.read(file).match? regexify(data)

            inject_into_file file, "\n#{data}", before: /^  end\nend/, verbose: false
          else
            data = optimize_indentation(data, 2)

            Array(options[:env]).each do |env|
              file = "config/environments/#{env}.rb"
              replace_existing file, data
              next if File.read(file).match? regexify(data)

              inject_into_file file, data, before: /^end/,
                                           verbose: false
            end
          end
        end
      end

      #
      # Set a application generator config
      # If the configuration exists already, it is replaced.
      #
      # @param [String] data the configuration string. e.g. `g.helper :my_helper`
      # @param [Hash] options optional options hash
      # @option options [String, Array(String), Array(Symbol)] :env environment specification config to update
      #
      # @return [void]
      #
      def environment_generator(data = nil, options = {})
        data ||= yield if block_given?

        log :environment_generator, data

        in_root do
          def replace_existing(file, data)
            gsub_file file, Regexp.new(".*#{data.split('=').first.strip}.*=.*\n"), data, verbose: false
          end

          def ensure_sentinel(file, sentinel)
            return if File.read(file).match?(/^#{Regexp.quote sentinel}/)

            inject_into_file file, "\n#{sentinel}#{optimize_indentation('end', 4)}", before: /^  end\nend/,
                                                                                     verbose: false
          end

          sentinel = optimize_indentation("config.generators do |g|\n", 4)

          if options[:env].nil?
            data = optimize_indentation(data, 6)
            file = 'config/application.rb'
            replace_existing file, data
            break if File.read(file).match? regexify(data)

            ensure_sentinel file, sentinel
            inject_into_file file, data, after: sentinel, verbose: false
          else
            data = optimize_indentation(data, 2)

            Array(options[:env]).each do |env|
              file = "config/environments/#{env}.rb"
              replace_existing file, data
              next if File.read(file).match? regexify(data)

              ensure_sentinel file, sentinel
              inject_into_file file, data, after: sentinel, verbose: false
            end
          end
        end
      end

      def gitignore(*directives)
        in_root do
          # Doing this one by one so that duplication detection during insertion will work
          directives.each do |directive|
            log :gitignore, directive
            insert_into_file '.gitignore', "#{directive}\n", verbose: false
          end
        end
      end

      # Similar to #run, this executes a command but returns both success and result.
      def run_captured(command, config = {})
        return [false, nil] unless behavior == :invoke

        destination = relative_to_original_destination_root(destination_root, false)
        desc = "#{command} from #{destination.inspect}"

        if config[:with]
          desc = "#{File.basename(config[:with].to_s)} #{desc}"
          command = "#{config[:with]} #{command}"
        end

        say_status :run, desc, config.fetch(:verbose, true)

        return if options[:pretend]

        env_splat = [config[:env]] if config[:env]

        result, status = Open3.capture2e(*env_splat, command.to_s)
        success = status.success?

        [success, result]
      end

      private

      def regexify(str)
        Regexp.new("^#{Regexp.quote str}".gsub(/['"]/, %(['"])))
      end

      def gemfile
        in_root do
          File.read('Gemfile')
        end
      end
    end
  end
end
