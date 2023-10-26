class PerformanceJob < ApplicationJob
  def perform(argument = nil, options = {})
    sleep 1
    Rails.logger.warn "Slowly delivered #{argument} (#{options})!"
  end
end
