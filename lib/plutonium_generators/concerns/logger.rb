# frozen_string_literal: true

module PlutoniumGenerators
  module Concerns
    module Logger
      def debug(msg)
        say "\e[33m#{format_log msg, :debug}\e[0m"
      end

      def info(msg)
        say "\e[34m#{format_log msg, :info}\e[0m\n"
      end

      def success(msg)
        say "\e[32m#{format_log msg, :success}\e[0m"
      end

      def error(msg)
        say "\e[31m#{format_log msg, :error}\e[0m\n"
        exit(1)
      end

      def exception(msg, err)
        error "#{msg}\n\n#{err}\n#{err.backtrace.join("\n")}"
      end

      private

      def format_log(msg, log_level)
        indent = ' ' * (log_level.length + 2)
        "#{log_level}: #{msg}".lines.join indent
      end
    end
  end
end
