# Target of a Sidekiq delayed job, used to check the AppSignal integration
# resolves a delayed wrapper job's action name to `GoalTestDelayedTarget.run`
# rather than the internal wrapper class.
class GoalTestDelayedTarget
  def self.run(argument = nil)
    puts "GoalTestDelayedTarget.run #{argument}"
  end
end
