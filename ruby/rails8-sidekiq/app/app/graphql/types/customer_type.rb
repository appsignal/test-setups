module Types
  class CustomerType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :tier, Types::CustomerTierEnum, null: false
    field :loyalty_points, Integer, null: false
    field :primary_address, Types::AddressType, null: false
    field :orders, [ "Types::OrderType" ], null: false do
      argument :status, Types::OrderStatusEnum, required: false
      argument :limit, Integer, required: false
    end
    field :total_spend, Types::MoneyType, null: false

    def full_name
      "#{object[:first_name]} #{object[:last_name]}"
    end

    def orders(status: nil, limit: nil)
      GraphqlDemoData.orders_for_customer(object[:id], status:, limit:)
    end

    def total_spend
      GraphqlDemoData.money(GraphqlDemoData.customer_total_spend_cents(object[:id]))
    end
  end
end
