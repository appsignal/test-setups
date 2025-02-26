class App
  class HttpResponseError < StandardError; end

  def initialize(name, url)
    @name = name
    @url = url
  end

  def self.from_env!
    new(ENV.fetch("APP_NAME"), ENV.fetch("APP_URL"))
  end

  attr_reader :name
  alias_method :to_s, :name

  def url(path = "")
    "#{@url}#{path}"
  end

  def backend?
    !@name.start_with?("javascript/")
  end

  def wait_for_start
    max_retries = 1200
    retries = 0

    begin
      response = HTTP.timeout(1).get(@url)
      unless response.status == 200
        raise HttpResponseError, "App is returning a #{response.status} status on boot. Retrying..."
      end
      puts "The app has started!"
    rescue HTTP::ConnectionError, HTTP::TimeoutError, HttpResponseError => error
      if retries >= max_retries
        puts "The app has not started after #{retries} retries. Exiting."
        exit! 1
      elsif retries % 5 == 0
        puts "The app has not started yet. Retrying... (#{retries}/#{max_retries})"
        puts "#{error.class}: #{error}"
        puts response.body
      end

      sleep 1
      retries += 1
      retry
    end
  end
end
