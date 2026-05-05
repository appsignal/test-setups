module Types
  class OrderStatusEnum < Types::BaseEnum
    graphql_name "OrderStatus"

    value "PENDING"
    value "PROCESSING"
    value "SHIPPED"
    value "DELIVERED"
    value "CANCELLED"
  end
end
