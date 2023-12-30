# frozen_string_literal: true

require "English"
require "factory_bot-awesome_linter"

namespace :factory_bot do
  desc(
    "Verify that all FactoryBot factories are valid.\n\n" \
    "USAGE: rails factory_bot:lint factory=factory_name"
  )
  task lint: :environment do
    if Rails.env.test?
      factory = ENV["factory"]
      factory.present? ? FactoryBot::AwesomeLinter.lint!(factory) : FactoryBot::AwesomeLinter.lint!
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      raise if $CHILD_STATUS.exitstatus.nonzero?
    end
  end
end
