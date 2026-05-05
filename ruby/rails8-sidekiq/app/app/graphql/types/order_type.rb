module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :order_number, String, null: false
    field :status, Types::OrderStatusEnum, null: false
    field :placed_at, GraphQL::Types::ISO8601DateTime, null: false
    field :billing_address, Types::AddressType, null: false
    field :shipping_address, Types::AddressType, null: false
    field :shipment, Types::ShipmentType, null: false
    field :line_items, [ Types::LineItemType ], null: false
    field :subtotal, Types::MoneyType, null: false
    field :total, Types::MoneyType, null: false
    field :customer, Types::CustomerType, null: false

    def subtotal
      GraphqlDemoData.money(GraphqlDemoData.order_subtotal_cents(object))
    end

    def total
      GraphqlDemoData.money(GraphqlDemoData.order_total_cents(object))
    end

    def customer
      GraphqlDemoData.customer(object[:customer_id])
    end
  end
end
