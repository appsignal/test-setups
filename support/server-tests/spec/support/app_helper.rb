module AppHelper
  def self.wait_for_app(url)
    max_retries = 1200
    retries = 0

    begin
      HTTP.timeout(1).get(url)
      puts "The app is alive!"
    rescue HTTP::ConnectionError, HTTP::TimeoutError
      if retries >= max_retries
        puts "The app is not alive after #{retries} retries. Exiting."
        exit! 1
      elsif retries % 5 == 0
        puts "The app is not alive yet. Retrying... (#{retries}/#{max_retries})"
      end
      sleep 1
      retries += 1
      retry
    end
  end
end
