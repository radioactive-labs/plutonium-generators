# frozen_string_literal: true

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq.logger

  config.death_handlers << lambda { |job, _exception|
    puts "Uh oh, #{job['class']} #{job['jid']} just died with error #{ex.message}."
  }

  config.redis = {
    # TODO: Set this to a dedicated Redis instance in prod
    # url: 'redis://localhost:6379/0',

    # https://stackoverflow.com/questions/66246528/herkou-redis-certificate-verify-failed-self-signed-certificate-in-certificate
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    # TODO: Set this to a dedicated Redis instance in prod
    # url: 'redis://localhost:6379/0',

    # https://stackoverflow.com/questions/66246528/herkou-redis-certificate-verify-failed-self-signed-certificate-in-certificate
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end
