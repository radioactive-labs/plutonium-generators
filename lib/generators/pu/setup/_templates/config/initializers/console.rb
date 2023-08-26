# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.console do
  # Clear the console.
  $stdout.clear_screen

  # Run any code we want before the console loads

  # Enable query logging
  ActiveRecord::Base.logger = Logger.new($stdout)

  # <<=pu
  # pu=>>
end
