module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :sku, String, null: false
    field :name, String, null: false
    field :category, String, null: false
    field :unit_price, Types::MoneyType, null: false
    field :supplier, Types::SupplierType, null: false
    field :inventory_snapshots, [ Types::InventorySnapshotType ], null: false

    def unit_price
      GraphqlDemoData.money(object[:unit_price_cents])
    end

    def supplier
      GraphqlDemoData.supplier(object[:supplier_id])
    end

    def inventory_snapshots
      GraphqlDemoData.inventory_for_product(object[:id])
    end
  end
end
