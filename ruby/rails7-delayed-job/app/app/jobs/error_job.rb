class ErrorJob
  def deliver(argument = nil, options = {})
    raise "Error #{argument}"
  end
  handle_asynchronously :deliver, :run_at => Proc.new { 1.minute.from_now }
end
