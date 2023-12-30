# frozen_string_literal: true

require File.expand_path("../../../../plutonium_generators", __dir__)

module Pu
  module Db
    class SeedGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator

      source_root File.expand_path("templates", __dir__)

      desc "Create a database seed"

      argument :name
      class_option :env, type: :string, default: "all"

      def start
        seed_number = Time.now.strftime "%Y%m%d%H%M%S"
        template "seed.rb.tt", "db/seeds/#{seed_number}_#{name.underscore}.#{seed_environment}.rb"
      rescue => e
        exception "Creating database seed failed:", e
      end

      protected

      def seed_environment
        options[:env].underscore
      end
    end
  end
end
