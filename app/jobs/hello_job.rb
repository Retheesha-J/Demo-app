class HelloJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "👋 Hello from Sidekiq! Args: #{args.inspect}"
  end
end
