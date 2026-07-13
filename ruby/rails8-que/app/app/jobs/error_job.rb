# A native Que job that raises, to exercise error reporting on the performed
# job. Enqueued with `ErrorJob.enqueue`, which records an `enqueue.que` event.
class ErrorJob < Que::Job
  def run(argument = nil)
    Rails.error.handle do
      1 + "1" # raises TypeError
    end
    raise "Error: #{argument}"
  end
end
