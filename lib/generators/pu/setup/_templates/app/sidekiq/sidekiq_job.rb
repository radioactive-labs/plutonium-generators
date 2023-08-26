# frozen_string_literal: true

class SidekiqJob
  include Sidekiq::Job

  sidekiq_options failures: :exhausted
end
