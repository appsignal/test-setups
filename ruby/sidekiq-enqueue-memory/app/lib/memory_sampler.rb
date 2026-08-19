# Reports the resident memory of the process it runs in.
#
# The customer saw this number in Heroku's `mem=580M(113.4%)` dyno lines. Those
# are sampled from outside the process every 20 seconds, which is too coarse to
# tell an allocation rate from a one off spike. Reading `/proc/self/status` from
# inside the Sidekiq process gives the same figure whenever we ask for it, so a
# run here can be compared against the customer's logs directly.
class MemorySampler
  # Written by the kernel in kilobytes.
  RSS_PATTERN = /^VmRSS:\s+(\d+) kB/

  def self.rss_bytes
    File.read("/proc/self/status")[RSS_PATTERN, 1].to_i * 1024
  rescue Errno::ENOENT
    # Not Linux. Every supported way of running this app is a Linux container,
    # so rather than guess at an equivalent, report zero and let the numbers
    # make it obvious.
    0
  end

  def initialize(label)
    @label = label
    @baseline = self.class.rss_bytes
    @started_at = monotonic_now
  end

  attr_reader :label, :baseline

  # Logs where memory stands after `enqueued` jobs have been pushed.
  #
  # The figure worth watching is bytes per enqueue. Reading the agent source
  # suggested roughly 250 bytes per recorded event, and the customer's growth
  # rate needs about 34,000 enqueues per second to be explained by that alone.
  # This line is what confirms or refutes that estimate.
  def checkpoint(enqueued)
    rss = self.class.rss_bytes
    growth = rss - baseline
    elapsed = monotonic_now - @started_at

    puts format(
      "[%s] enqueued=%-9d rss=%-9s growth=%-9s bytes_per_enqueue=%-7s rate=%s",
      label,
      enqueued,
      format_bytes(rss),
      format_bytes(growth),
      enqueued.positive? ? (growth.to_f / enqueued).round : "n/a",
      elapsed.positive? ? "#{format_bytes(growth / elapsed)}/s" : "n/a"
    )
  end

  def summary(enqueued)
    growth = self.class.rss_bytes - baseline
    elapsed = monotonic_now - @started_at

    puts "[#{label}] ---- run complete ----"
    puts "[#{label}] enqueued:          #{enqueued}"
    puts "[#{label}] resident growth:   #{format_bytes(growth)}"
    puts "[#{label}] elapsed:           #{elapsed.round(1)}s"
    puts "[#{label}] bytes per enqueue: #{enqueued.positive? ? (growth.to_f / enqueued).round : "n/a"}"
    puts "[#{label}] growth rate:       #{elapsed.positive? ? "#{format_bytes(growth / elapsed)}/s" : "n/a"}"
    puts "[#{label}] enqueue events:    #{enqueue_instrumentation_enabled? ? "recorded" : "suppressed"}"
  end

  def enqueue_instrumentation_enabled?
    Appsignal.config && Appsignal.config[:enable_job_enqueue_instrumentation]
  end

  private

  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def format_bytes(bytes)
    "#{(bytes.to_f / (1024 * 1024)).round(1)}MB"
  end
end
