role = ENV.fetch("APP_ROLE")

puts "Starting Mongo #{role} app"

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'mongo'
end

require "mongo"

# Requiring `mongo` changes some standard output buffering setting
# for some reason -- this undoes it so that output is not buffered.
$stdout.sync = true

FRUITS = ["apple", "banana", "strawberry", "mango", "kiwi"]

threads = []

FRUITS.each do |fruit|
  threads << Thread.new do
    puts "Connecting to Mongo (#{fruit}, #{role})"

    client = Mongo::Client.new(ENV.fetch("MONGODB_URL"))
    collection = client[:fruits]

    i = 0

    loop do
      case role
      when "write"
        puts "Inserting #{fruit} documents ##{i}"

        collection.insert_one({
          fruit: fruit,
          updated: false,
          i: i
        })

      when "read"
        count = collection.find({
          fruit: fruit
        }).count_documents

        puts "Counted #{count} #{fruit} documents"

      when "update"
        document = collection.find({
          fruit: fruit,
          updated: false
        }).first

        if document
          puts "Updating #{fruit} document ##{document[:i]}"

          collection.update_one(
            {
              fruit: fruit,
              updated: false,
              i: document[:i]
            },
            {
              "$set": {
                updated: true
              }
            }
          )
        end

      when "delete"
        document = collection.find({
          fruit: fruit,
          updated: true
        }).first

        if document
          puts "Deleting updated #{fruit} document ##{document[:i]}"

          collection.delete_one({
            fruit: fruit,
            updated: true,
            i: document[:i]
          })
        end
      end

      i = i + 1

      sleep 10
    end
  end

  sleep 2
end

threads.each(&:join)
