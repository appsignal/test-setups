# Boot file for the Sidekiq process, loaded with `sidekiq -r ./worker.rb`.
#
# Sidekiq has to be defined before Appsignal.start, because the Sidekiq hook
# only installs itself when it can see the constant. Requiring it afterwards
# leaves the process running with no Sidekiq instrumentation at all, which would
# make every measurement here come out flat for the wrong reason.
require "sidekiq"
require "appsignal"

Appsignal.start

# A run with AppSignal inactive reports flat memory, which looks exactly like
# the result that would clear the enqueue instrumentation. Fail loudly instead,
# so a misconfigured run cannot be mistaken for a finding.
unless Appsignal.active?
  abort <<~MESSAGE
    AppSignal did not activate in the Sidekiq process, so there is nothing to
    measure. Check that APPSIGNAL_APP_ENV matches an environment listed in
    config/appsignal.rb, and that APPSIGNAL_PUSH_API_KEY is set.
  MESSAGE
end

puts "[worker] AppSignal #{Appsignal::VERSION} active in #{Appsignal.config.env}"
puts "[worker] enqueue instrumentation: " \
  "#{Appsignal.config[:enable_job_enqueue_instrumentation] ? "on" : "off"}"

require_relative "jobs"

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV.fetch("REDIS_URL", "redis://redis:6379") }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV.fetch("REDIS_URL", "redis://redis:6379") }
end
