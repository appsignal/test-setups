module Types
  class QueryType < Types::BaseObject
    field :customer, Types::CustomerType, null: true do
      argument :id, ID, required: true
    end

    field :customers, [ Types::CustomerType ], null: false do
      argument :tier, Types::CustomerTierEnum, required: false
      argument :limit, Integer, required: false, default_value: 20
    end

    field :order, Types::OrderType, null: true do
      argument :id, ID, required: true
    end

    field :warehouse, Types::WarehouseType, null: true do
      argument :id, ID, required: true
    end

    field :warehouses, [ Types::WarehouseType ], null: false

    field :search_products, [ Types::ProductType ], null: false do
      argument :query, String, required: true
      argument :limit, Integer, required: false, default_value: 10
    end

    def customer(id:)
      GraphqlDemoData.customer(id)
    end

    def customers(tier: nil, limit: 20)
      GraphqlDemoData.customers(tier:, limit:)
    end

    def order(id:)
      GraphqlDemoData.order(id)
    end

    def warehouse(id:)
      GraphqlDemoData.warehouse(id)
    end

    def warehouses
      GraphqlDemoData.warehouses
    end

    def search_products(query:, limit: 10)
      GraphqlDemoData.search_products(query, limit)
    end
  end
end
