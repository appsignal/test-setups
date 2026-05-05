module Types
  class AddressType < Types::BaseObject
    field :line1, String, null: false
    field :line2, String, null: true
    field :city, String, null: false
    field :state, String, null: false
    field :postal_code, String, null: false
    field :country, String, null: false
  end
end
