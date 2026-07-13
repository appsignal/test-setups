# A native Resque job that raises, to exercise error reporting on the performed
# job. Enqueued with `Resque.enqueue`, which records an `enqueue.resque` event.
class ErrorJob
  @queue = :default

  def self.perform(argument = nil)
    Rails.error.handle do
      1 + "1" # raises TypeError
    end
    raise "Error: #{argument}"
  end
end
