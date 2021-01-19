require_relative "./workers"

5.times do |i|
  SingleWorker.perform_async({ :body => "message #{i}"})
  BatchedWorker.perform_async({ :body => "message #{i}"})
end
