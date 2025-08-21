#!/usr/bin/env ruby

require "net/http"
require "uri"
require "json"

class WebshopLoadTester
  BASE_URL = "http://localhost:4001"
  
  # All webshop endpoints with their HTTP methods
  ENDPOINTS = [
    # Product endpoints
    { method: "GET", path: "/products" },
    { method: "GET", path: "/products/123" },
    { method: "GET", path: "/products/456" },
    { method: "GET", path: "/products/789" },
    { method: "GET", path: "/products/search" },
    { method: "GET", path: "/categories" },
    { method: "GET", path: "/categories/electronics/products" },
    { method: "GET", path: "/categories/clothing/products" },
    { method: "GET", path: "/categories/books/products" },
    
    # Cart endpoints
    { method: "GET", path: "/cart" },
    { method: "POST", path: "/cart/add" },
    { method: "PUT", path: "/cart/update" },
    { method: "DELETE", path: "/cart/remove" },
    
    # Account endpoints
    { method: "POST", path: "/login" },
    { method: "POST", path: "/register" },
    { method: "GET", path: "/account" },
    { method: "GET", path: "/account/profile" },
    { method: "GET", path: "/account/orders" },
    { method: "GET", path: "/account/addresses" },
    { method: "GET", path: "/account/wishlist" },
    
    # Support endpoints (these don't have random errors but still good to test)
    { method: "GET", path: "/help" },
    { method: "GET", path: "/contact" },
    { method: "GET", path: "/returns" },
    { method: "GET", path: "/shipping" },
    
    # Checkout endpoint
    { method: "GET", path: "/checkout" }
  ]
  
  def initialize
    @running = false
  end
  
  def start
    @running = true
    puts "🚀 Starting webshop load tester..."
    puts "📡 Target: #{BASE_URL}"
    puts "🔄 Making requests to #{ENDPOINTS.length} endpoints"
    puts "💡 Press Ctrl+C to stop"
    puts
    
    # Create threads for concurrent requests
    threads = []
    
    # Start a thread for each endpoint
    ENDPOINTS.each_with_index do |endpoint, index|
      threads << Thread.new do
        request_loop(endpoint, index)
      end
    end
    
    # Wait for interrupt
    begin
      threads.each(&:join)
    rescue Interrupt
      puts "\n🛑 Stopping load tester..."
      @running = false
      threads.each(&:kill)
    end
  end
  
  private
  
  def request_loop(endpoint, thread_id)
    while @running
      begin
        # Random sleep between 2-8 seconds before each request
        sleep_time = 2 + rand(6)
        sleep(sleep_time)
        
        next unless @running
        
        make_request(endpoint, thread_id)
      rescue => e
        puts "❌ Thread #{thread_id}: Error making request: #{e.message}"
      end
    end
  end
  
  def make_request(endpoint, thread_id)
    uri = URI("#{BASE_URL}#{endpoint[:path]}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 10
    http.open_timeout = 5
    
    case endpoint[:method]
    when "GET"
      request = Net::HTTP::Get.new(uri)
    when "POST"
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = generate_sample_data(endpoint[:path])
    when "PUT"
      request = Net::HTTP::Put.new(uri)
      request["Content-Type"] = "application/json"
      request.body = generate_sample_data(endpoint[:path])
    when "DELETE"
      request = Net::HTTP::Delete.new(uri)
    end
    
    start_time = Time.now
    response = http.request(request)
    duration = ((Time.now - start_time) * 1000).round(2)
    
    status_emoji = case response.code.to_i
    when 200..299
      "✅"
    when 400..499
      "⚠️"
    when 500..599
      "❌"
    else
      "❓"
    end
    
    puts "#{status_emoji} [T#{thread_id.to_s.rjust(2)}] #{endpoint[:method].ljust(6)} #{endpoint[:path].ljust(30)} #{response.code} (#{duration}ms)"
    
  rescue Net::TimeoutError
    puts "⏰ [T#{thread_id.to_s.rjust(2)}] #{endpoint[:method].ljust(6)} #{endpoint[:path].ljust(30)} TIMEOUT"
  rescue Errno::ECONNREFUSED
    puts "🔌 [T#{thread_id.to_s.rjust(2)}] #{endpoint[:method].ljust(6)} #{endpoint[:path].ljust(30)} CONNECTION_REFUSED"
  rescue => e
    puts "💥 [T#{thread_id.to_s.rjust(2)}] #{endpoint[:method].ljust(6)} #{endpoint[:path].ljust(30)} ERROR: #{e.class.name}"
  end
  
  def generate_sample_data(path)
    case path
    when "/login"
      { email: "user#{rand(1000)}@example.com", password: "password123" }.to_json
    when "/register"
      { 
        name: "User #{rand(1000)}", 
        email: "newuser#{rand(1000)}@example.com", 
        password: "password123" 
      }.to_json
    when "/cart/add"
      { product_id: rand(1000), quantity: rand(1..5) }.to_json
    when "/cart/update"
      { product_id: rand(1000), quantity: rand(1..10) }.to_json
    else
      {}.to_json
    end
  end
end

if __FILE__ == $0
  tester = WebshopLoadTester.new
  tester.start
end