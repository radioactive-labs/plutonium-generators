# frozen_string_literal: true

module PlutoniumGenerators
  class Railtie < Rails::Railtie
    # add railties here

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
