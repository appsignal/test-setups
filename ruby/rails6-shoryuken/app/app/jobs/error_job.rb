class ErrorJob < ApplicationJob
  queue_as :default

  def perform(msg)
    raise "Error: #{argument} (#{options})"
  end
end
