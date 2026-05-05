class GraphqlController < ApplicationController
  skip_forgery_protection

  def execute
    if batch_request?
      render json: ExampleAppSchema.multiplex(multiplex_payload)
    else
      render json: ExampleAppSchema.execute(
        params[:query],
        variables: prepare_variables(params[:variables]),
        operation_name: params[:operationName],
        context: graphql_context
      )
    end
  rescue StandardError => e
    render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
  ensure
    transaction_name = params[:operationName] || "Unknown"
    puts "!!! controller transaction name: #{transaction_name}"
    Appsignal::Transaction.current.set_action(transaction_name)
  end

  private

  def batch_request?
    params[:_json].is_a?(Array)
  end

  def multiplex_payload
    params[:_json].map do |entry|
      payload = normalize_entry(entry)
      puts "!!! controller multiplex action name: #{payload["operationName"] || payload[:operationName]}"
      {
        query: payload["query"] || payload[:query],
        variables: prepare_variables(payload["variables"] || payload[:variables]),
        operation_name: payload["operationName"] || payload[:operationName],
        context: graphql_context
      }
    end
  end

  def normalize_entry(entry)
    if entry.respond_to?(:to_unsafe_h)
      entry.to_unsafe_h
    else
      entry.to_h
    end
  end

  def graphql_context
    {
      request_id: request.request_id,
      remote_ip: request.remote_ip,
      :set_appsignal_action_name => true
    }
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? prepare_variables(JSON.parse(variables_param)) : {}
    when ActionController::Parameters
      variables_param.to_unsafe_h
    when Hash
      variables_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables format: #{variables_param.class}"
    end
  end
end
