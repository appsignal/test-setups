module Types
  class CustomerTierEnum < Types::BaseEnum
    graphql_name "CustomerTier"

    value "BRONZE"
    value "SILVER"
    value "GOLD"
    value "PLATINUM"
  end
end
