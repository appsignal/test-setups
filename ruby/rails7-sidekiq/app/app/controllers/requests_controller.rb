class RequestsController < ApplicationController
  skip_forgery_protection

  # The HTTP client actions call a second, separately-instrumented app (the
  # `downstream` service) so the injected `traceparent` is extracted there and
  # the trace spans both apps. Falls back to calling this app itself when
  # DOWNSTREAM_URL is unset, so the setup still works as a single service.
  def self.downstream_url(path)
    "#{ENV.fetch("DOWNSTREAM_URL", "http://localhost:4001")}#{path}"
  end

  def perform_excon_get
    handle_response Excon.get(self.class.downstream_url("/requests/excon_get?query=param"))
  end

  def perform_excon_post
    handle_response Excon.post(
      self.class.downstream_url("/requests/excon_post"),
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_put
    handle_response Excon.put(
      self.class.downstream_url("/requests/excon_put"),
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_delete
    handle_response Excon.delete(
      self.class.downstream_url("/requests/excon_delete"),
      :body => URI.encode_www_form(:language => "ruby", :class => "fog"),
      :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
    )
  end

  def perform_excon_head
    handle_response Excon.head(self.class.downstream_url("/requests/excon_get"))
  end

  def perform_excon_options
    handle_response Excon.options(self.class.downstream_url("/requests/excon_options"))
  end

  def perform_excon_trace
    handle_response Excon.trace(self.class.downstream_url("/requests/excon_trace"))
  end

  # Hits the downstream app so the request span continues into it. (Previously
  # this called example.com, which is uninstrumented, so nothing continued.)
  def perform_http_rb_get
    HTTP.get(self.class.downstream_url("/requests/http_rb_target"))
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  # In http 6 a chained request (`HTTP.follow.get`, `HTTP.headers(...).get`,
  # etc.) runs through `HTTP::Session#request` instead of `HTTP::Client#request`.
  # These actions exercise that path so it records a `request.http_rb` event.
  def perform_http_rb_headers
    HTTP.headers("X-Custom-Header" => "AppSignal")
      .get(self.class.downstream_url("/requests/http_rb_target"))
    redirect_to requests_path, :notice => %(Request "#{params[:action]}" made)
  end

  # A followed redirect should stay a single `request.http_rb` event spanning
  # every hop, not one event per hop.
  def perform_http_rb_follow
    HTTP.follow.get(self.class.downstream_url("/requests/http_rb_redirect"))
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
    handle_response Faraday.get(self.class.downstream_url("/requests/faraday_get?query=param"))
  end

  def perform_faraday_post
    handle_response Faraday.post(
      self.class.downstream_url("/requests/faraday_post"),
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
