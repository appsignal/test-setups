module Types
  class InventorySnapshotType < Types::BaseObject
    field :product_id, ID, null: false
    field :warehouse_id, ID, null: false
    field :available, Integer, null: false
    field :reserved, Integer, null: false
    field :reorder_threshold, Integer, null: false
    field :on_hand, Integer, null: false

    def on_hand
      object[:available] + object[:reserved]
    end
  end
end
