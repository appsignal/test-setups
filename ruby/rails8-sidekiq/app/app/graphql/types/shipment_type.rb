module Types
  class ShipmentType < Types::BaseObject
    field :carrier, String, null: false
    field :service_level, String, null: false
    field :tracking_number, String, null: false
    field :estimated_delivery_on, GraphQL::Types::ISO8601Date, null: false
    field :shipped_at, GraphQL::Types::ISO8601DateTime, null: true
    field :status, String, null: false
  end
end
