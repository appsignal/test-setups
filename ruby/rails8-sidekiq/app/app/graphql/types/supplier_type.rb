module Types
  class SupplierType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :region, String, null: false
    field :rating, Float, null: false
  end
end
