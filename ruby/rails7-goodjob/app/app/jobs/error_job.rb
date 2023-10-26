class ErrorJob < ApplicationJob
  def perform(argument = nil, options = {})
    Rails.logger.warn "Erroring job #{argument} (#{options})!"
    raise "Error: #{argument} (#{options})"
  end
end
