class RequestsController < ApplicationController
  skip_forgery_protection

  def perform_excon_get
    handle_response Excon.get("http://localhost:4001/requests/excon_get?query=param")
  end

  def perform_excon_post
    handle_response Excon.post(
      "http://localhost:4001/requests/excon_post",
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_put
    handle_response Excon.put(
      "http://localhost:4001/requests/excon_put",
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_delete
    handle_response Excon.delete(
      "http://localhost:4001/requests/excon_delete",
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_head
    handle_response Excon.head("http://localhost:4001/requests/excon_get")
  end

  def perform_excon_options
    handle_response Excon.options("http://localhost:4001/requests/excon_options")
  end

  def perform_excon_trace
    handle_response Excon.trace("http://localhost:4001/requests/excon_trace")
  end

  def perform_http_rb_get
    HTTP.get("https://example.com")
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  # In http 6 a chained request (`HTTP.follow.get`, `HTTP.headers(...).get`,
  # etc.) runs through `HTTP::Session#request` instead of `HTTP::Client#request`.
  # These actions exercise that path so it records a `request.http_rb` event.
  def perform_http_rb_headers
    HTTP.headers("X-Custom-Header" => "AppSignal")
      .get("http://localhost:4001/requests/http_rb_target")
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  # A followed redirect should stay a single `request.http_rb` event spanning
  # every hop, not one event per hop.
  def perform_http_rb_follow
    HTTP.follow.get("http://localhost:4001/requests/http_rb_redirect")
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  def http_rb_target
    sleep 1
    render :html => "HTTP.rb request target"
  end

  def http_rb_redirect
    redirect_to http_rb_target_requests_path
  end

  # Faraday defaults to the Net::HTTP adapter, so this also exercises AppSignal
  # suppressing the downstream Net::HTTP event: the request should be recorded
  # once, as a `request.faraday` event.
  def perform_faraday_get
    handle_response Faraday.get("http://localhost:4001/requests/faraday_get?query=param")
  end

  def perform_faraday_post
    handle_response Faraday.post(
      "http://localhost:4001/requests/faraday_post",
      URI.encode_www_form(:language => "ruby", :library => "faraday"),
      "Content-Type" => "application/x-www-form-urlencoded"
    )
  end

  def faraday_get
    sleep 1
    render :html => "Faraday GET request"
  end

  def faraday_post
    sleep 1
    render :html => "Faraday POST request"
  end

  def handle_response(response)
    unless response.status == 200
      raise "Request failed with status #{response.status}"
    end
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  def excon_get
    sleep 1
    render :html => "Excon GET request"
  end

  def excon_post
    sleep 1
    render :html => "Excon POST request"
  end

  def excon_put
    sleep 1
    render :html => "Excon PUT request"
  end

  def excon_delete
    sleep 1
    render :html => "Excon DELETE request"
  end

  def excon_options
    sleep 1
    render :html => "Excon OPTIONS request"
  end

  def excon_trace
    sleep 1
    render :html => "Excon TRACE request"
  end
end
