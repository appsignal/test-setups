class ExampleAppSchema < GraphQL::Schema
  trace_with(GraphQL::Tracing::AppsignalTrace)
  query Types::QueryType
end
