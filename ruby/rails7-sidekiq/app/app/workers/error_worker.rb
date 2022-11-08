class ErrorWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(argument = nil, options = {})
    raise "Error: #{argument}"
  end
end
