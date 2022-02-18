class RequestsController < ApplicationController
  skip_forgery_protection

  def perform_excon_get
    handle_response Excon.get("http://localhost:4001/requests/excon_get")
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
