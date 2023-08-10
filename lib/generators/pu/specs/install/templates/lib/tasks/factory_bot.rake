# frozen_string_literal: true

require 'English'

namespace :factory_bot do
  desc(
    "Verify that all FactoryBot factories are valid.\n\n" \
    'USAGE: rails factory_bot:lint factory=factory_name'
  )
  task lint: :environment do
    if Rails.env.test?
      FactoryBot::AwesomeLinter.lint! ENV['factory']
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      raise if $CHILD_STATUS.exitstatus.nonzero?
    end
  end
end
