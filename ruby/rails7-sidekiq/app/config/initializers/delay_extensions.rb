require "sidekiq/delay_extensions"

# Restores Sidekiq's `.delay` extensions, which were removed from Sidekiq 7.
Sidekiq::DelayExtensions.enable_delay!

# The extraction gem defines the delayed job classes under
# `Sidekiq::DelayExtensions`, but jobs enqueued by older Sidekiq versions use
# the `Sidekiq::Extensions` namespace. That legacy namespace is also the one
# the AppSignal integration recognizes when resolving a delayed job's action
# name. Alias it so such a job can be constantized and performed here.
module Sidekiq
  module Extensions
  end
end
Sidekiq::Extensions::DelayedClass = Sidekiq::DelayExtensions::DelayedClass
Sidekiq::Extensions::DelayedModel = Sidekiq::DelayExtensions::DelayedModel
