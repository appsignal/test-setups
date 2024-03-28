desc "Continuously enqueue jobs"
task :enqueue_jobs => :environment do
  loop do
    ErrorJob.perform_later("error job")
    PerformanceJob.perform_later("performance job")
    sleep(rand(1..10))
  end
end
