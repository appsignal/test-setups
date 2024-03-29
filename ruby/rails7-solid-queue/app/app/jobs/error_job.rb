class ErrorJob < ApplicationJob
  def perform(argument)
    raise "Error #{argument}"
  end
end
