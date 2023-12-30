# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Setup
    class MailCatcherGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include PlutoniumGenerators::Installer

      desc "Setup Rails"

      def start
        install! :mail_catcher
      end

      protected

      def install_v0_1_0!
        docker_compose :mail_catcher

        in_root do
          gsub_file "config/environments/development.rb", "# Don't care if the mailer can't send.",
            "# Raise errors mailer can't send."
        end
        environment "config.action_mailer.raise_delivery_errors = true", env: :development

        environment "config.action_mailer.delivery_method = :smtp", env: :development
        environment "config.action_mailer.smtp_settings = { address: ENV.fetch('MAILCATCHER_HOST', '127.0.0.1'), port: 1_025 }",
          env: :development
      end
    end
  end
end
