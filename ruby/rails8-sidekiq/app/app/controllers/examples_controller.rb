require "net/http"
require "json"

class ReportError < StandardError; end

class ExamplesController < ApplicationController
  owner :examples

  def index
    Rails.logger.info(
      "Test log message",
      abc: "def",
      # Attribute value with quotes in them
      params: { "foo" => "bar", "abc" => "def" },
      # This tag should also show up
      final_tag: "test"
    )
    session[:user_id] = :some_user_id_123
    session[:menu] = { :state => :open, :view => :full }
  end

  def slow
    sleep 3
  end

  def error
    raise "This is a Rails error!"
  end

  def error_cause
    CauseCauser.new.error
  rescue => e
    puts e.backtrace
    raise "Error with error cause"
  end

  def custom_error
    raise "uh oh"
  rescue StandardError => error
    Appsignal.send_error(error) do
      Appsignal.apply_request(request)
    end

    raise
  end

  def error_reporter
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    render :html => "An error has been reported through the Rails error reporter"
  end

  def graphql_demo
    query = <<~GRAPHQL
      query CustomerOverview($customerId: ID!, $ordersLimit: Int!, $status: OrderStatus) {
        customer(id: $customerId) {
          id
          fullName
          tier
          loyaltyPoints
          primaryAddress {
            city
            country
          }
          orders(limit: $ordersLimit, status: $status) {
            id
            orderNumber
            status
            total {
              amount
              currency
            }
            lineItems {
              sku
              quantity
              totalPrice {
                amount
                currency
              }
              product {
                id
                name
                category
                supplier {
                  name
                  region
                }
              }
            }
            shipment {
              carrier
              trackingNumber
              estimatedDeliveryOn
            }
          }
        }
      }

      query WarehouseOperations($warehouseId: ID!, $productQuery: String!, $limit: Int!) {
        warehouse(id: $warehouseId) {
          id
          code
          name
          address {
            city
            country
          }
          inventorySnapshots {
            productId
            available
            reserved
            reorderThreshold
            onHand
          }
        }
        searchProducts(query: $productQuery, limit: $limit) {
          id
          name
          category
          unitPrice {
            amount
            currency
          }
          supplier {
            id
            name
          }
        }
      }
    GRAPHQL

    batch_payload = [
      {
        query: query,
        operationName: "CustomerOverview",
        variables: {
          customerId: "cust-001",
          ordersLimit: 2,
          status: "SHIPPED"
        }
      },
      {
        query: query,
        operationName: "WarehouseOperations",
        variables: {
          warehouseId: "wh-east-1",
          productQuery: "pro",
          limit: 3
        }
      }
    ]

    response = post_graphql_request(batch_payload)

    render json: {
      description: "Batch request with multiple operationName values in one HTTP request",
      request_payload: batch_payload,
      graphql_response: response[:body]
    }, status: response[:status]
  end

  def queries
    user_count = User.count
    User.destroy_all if user_count > 10_000

    2.times do |i|
      User.create!(:name => "User ##{user_count + i}")
    end
    @users = User.all
  end

  private

  def post_graphql_request(payload)
    uri = URI.parse("#{request.base_url}/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = http.request(request)
    {
      status: response.code.to_i,
      body: JSON.parse(response.body)
    }
  rescue JSON::ParserError
    {
      status: :bad_gateway,
      body: {
        errors: [
          {
            message: "GraphQL endpoint returned invalid JSON",
            raw_body: response&.body
          }
        ]
      }
    }
  end
end

class CauseCauser
  class WrappedError < StandardError; end
  class ExampleError < StandardError; end

  def error
    example_error
  rescue
    raise WrappedError, "my wrapped error message"
  end

  private

  def example_error
    deep_error
  rescue
    raise ExampleError, "my example error message"
  end

  def deep_error
    raise "Original error cause"
  end
end
