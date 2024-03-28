class ErrorJob < ApplicationJob
  def deliver(argument)
    raise "Error #{argument}"
  end
end
