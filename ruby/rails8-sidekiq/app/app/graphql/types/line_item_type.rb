module Types
  class LineItemType < Types::BaseObject
    field :sku, String, null: false
    field :quantity, Integer, null: false
    field :unit_price, Types::MoneyType, null: false
    field :discount, Types::MoneyType, null: false
    field :total_price, Types::MoneyType, null: false
    field :product, Types::ProductType, null: false

    def unit_price
      GraphqlDemoData.money(object[:unit_price_cents])
    end

    def discount
      GraphqlDemoData.money(object[:discount_cents])
    end

    def total_price
      GraphqlDemoData.money(GraphqlDemoData.line_item_total_cents(object))
    end

    def product
      GraphqlDemoData.product(object[:product_id])
    end
  end
end
