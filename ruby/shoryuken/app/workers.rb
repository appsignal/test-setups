require_relative "./boot"

Dir["workers/**/*.rb"].each do |file|
  require_relative file
end
