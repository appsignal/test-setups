module Types
  class WarehouseType < Types::BaseObject
    field :id, ID, null: false
    field :code, String, null: false
    field :name, String, null: false
    field :timezone, String, null: false
    field :address, Types::AddressType, null: false
    field :inventory_snapshots, [ Types::InventorySnapshotType ], null: false do
      argument :product_ids, [ ID ], required: false
    end

    def inventory_snapshots(product_ids: nil)
      GraphqlDemoData.inventory_for_warehouse(object[:id], product_ids:)
    end
  end
end
