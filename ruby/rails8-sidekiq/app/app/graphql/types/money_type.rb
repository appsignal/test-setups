module Types
  class MoneyType < Types::BaseObject
    field :amount, Float, null: false
    field :currency, String, null: false
  end
end
