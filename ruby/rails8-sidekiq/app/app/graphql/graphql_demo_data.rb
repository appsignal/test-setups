module GraphqlDemoData
  module_function

  SUPPLIERS = [
    { id: "sup-001", name: "Northwind Parts Co.", region: "North America", rating: 4.7 },
    { id: "sup-002", name: "Helios Fabrication", region: "Europe", rating: 4.4 },
    { id: "sup-003", name: "Pacific Components", region: "APAC", rating: 4.8 }
  ].freeze

  PRODUCTS = [
    {
      id: "prod-001",
      sku: "PRM-CHAIR-01",
      name: "Pro Ergonomic Chair",
      category: "furniture",
      supplier_id: "sup-001",
      unit_price_cents: 42_500
    },
    {
      id: "prod-002",
      sku: "STM-DESK-02",
      name: "Standing Desk Max",
      category: "furniture",
      supplier_id: "sup-002",
      unit_price_cents: 75_000
    },
    {
      id: "prod-003",
      sku: "MKY-KEYB-03",
      name: "Mechanical Keyboard Pro",
      category: "accessories",
      supplier_id: "sup-003",
      unit_price_cents: 13_500
    },
    {
      id: "prod-004",
      sku: "4K-MON-04",
      name: "4K Monitor 27in",
      category: "displays",
      supplier_id: "sup-001",
      unit_price_cents: 31_999
    }
  ].freeze

  CUSTOMERS = [
    {
      id: "cust-001",
      email: "alex.rivera@example.com",
      first_name: "Alex",
      last_name: "Rivera",
      tier: "GOLD",
      loyalty_points: 12_450,
      primary_address: {
        line1: "145 Spring St",
        line2: nil,
        city: "New York",
        state: "NY",
        postal_code: "10012",
        country: "US"
      }
    },
    {
      id: "cust-002",
      email: "mina.cho@example.com",
      first_name: "Mina",
      last_name: "Cho",
      tier: "SILVER",
      loyalty_points: 3_880,
      primary_address: {
        line1: "24 Docklands Ave",
        line2: "Unit 8",
        city: "Melbourne",
        state: "VIC",
        postal_code: "3008",
        country: "AU"
      }
    }
  ].freeze

  WAREHOUSES = [
    {
      id: "wh-east-1",
      code: "USE1",
      name: "US East Fulfillment",
      timezone: "America/New_York",
      address: {
        line1: "200 Harbor Rd",
        line2: nil,
        city: "Newark",
        state: "NJ",
        postal_code: "07105",
        country: "US"
      }
    },
    {
      id: "wh-eu-1",
      code: "EUC1",
      name: "EU Central Fulfillment",
      timezone: "Europe/Amsterdam",
      address: {
        line1: "75 Kanaalweg",
        line2: nil,
        city: "Rotterdam",
        state: "ZH",
        postal_code: "3011",
        country: "NL"
      }
    }
  ].freeze

  INVENTORY_SNAPSHOTS = [
    { warehouse_id: "wh-east-1", product_id: "prod-001", available: 72, reserved: 8, reorder_threshold: 15 },
    { warehouse_id: "wh-east-1", product_id: "prod-002", available: 19, reserved: 4, reorder_threshold: 10 },
    { warehouse_id: "wh-east-1", product_id: "prod-003", available: 205, reserved: 13, reorder_threshold: 40 },
    { warehouse_id: "wh-east-1", product_id: "prod-004", available: 34, reserved: 3, reorder_threshold: 8 },
    { warehouse_id: "wh-eu-1", product_id: "prod-001", available: 14, reserved: 2, reorder_threshold: 7 },
    { warehouse_id: "wh-eu-1", product_id: "prod-003", available: 89, reserved: 5, reorder_threshold: 20 }
  ].freeze

  ORDERS = [
    {
      id: "ord-1001",
      order_number: "SO-2026-1001",
      customer_id: "cust-001",
      status: "SHIPPED",
      placed_at: Time.utc(2026, 3, 10, 14, 15, 0),
      billing_address: {
        line1: "145 Spring St",
        line2: nil,
        city: "New York",
        state: "NY",
        postal_code: "10012",
        country: "US"
      },
      shipping_address: {
        line1: "145 Spring St",
        line2: nil,
        city: "New York",
        state: "NY",
        postal_code: "10012",
        country: "US"
      },
      shipment: {
        carrier: "DHL",
        service_level: "EXPRESS",
        tracking_number: "DHL123456789US",
        estimated_delivery_on: Date.new(2026, 3, 14),
        shipped_at: Time.utc(2026, 3, 11, 9, 5, 0),
        status: "IN_TRANSIT"
      },
      line_items: [
        { sku: "PRM-CHAIR-01", quantity: 2, product_id: "prod-001", unit_price_cents: 42_500, discount_cents: 3_000 },
        { sku: "MKY-KEYB-03", quantity: 1, product_id: "prod-003", unit_price_cents: 13_500, discount_cents: 0 }
      ]
    },
    {
      id: "ord-1002",
      order_number: "SO-2026-1027",
      customer_id: "cust-001",
      status: "PROCESSING",
      placed_at: Time.utc(2026, 4, 1, 8, 45, 0),
      billing_address: {
        line1: "145 Spring St",
        line2: nil,
        city: "New York",
        state: "NY",
        postal_code: "10012",
        country: "US"
      },
      shipping_address: {
        line1: "605 Market St",
        line2: "Suite 300",
        city: "San Francisco",
        state: "CA",
        postal_code: "94105",
        country: "US"
      },
      shipment: {
        carrier: "UPS",
        service_level: "GROUND",
        tracking_number: "",
        estimated_delivery_on: Date.new(2026, 4, 6),
        shipped_at: nil,
        status: "LABEL_CREATED"
      },
      line_items: [
        { sku: "STM-DESK-02", quantity: 1, product_id: "prod-002", unit_price_cents: 75_000, discount_cents: 5_000 },
        { sku: "4K-MON-04", quantity: 2, product_id: "prod-004", unit_price_cents: 31_999, discount_cents: 2_000 }
      ]
    },
    {
      id: "ord-1003",
      order_number: "SO-2026-1055",
      customer_id: "cust-002",
      status: "DELIVERED",
      placed_at: Time.utc(2026, 2, 20, 22, 10, 0),
      billing_address: {
        line1: "24 Docklands Ave",
        line2: "Unit 8",
        city: "Melbourne",
        state: "VIC",
        postal_code: "3008",
        country: "AU"
      },
      shipping_address: {
        line1: "24 Docklands Ave",
        line2: "Unit 8",
        city: "Melbourne",
        state: "VIC",
        postal_code: "3008",
        country: "AU"
      },
      shipment: {
        carrier: "FedEx",
        service_level: "PRIORITY",
        tracking_number: "FX5566778899",
        estimated_delivery_on: Date.new(2026, 2, 25),
        shipped_at: Time.utc(2026, 2, 21, 6, 30, 0),
        status: "DELIVERED"
      },
      line_items: [
        { sku: "MKY-KEYB-03", quantity: 3, product_id: "prod-003", unit_price_cents: 13_500, discount_cents: 1_500 }
      ]
    }
  ].freeze

  def customer(id)
    CUSTOMERS.find { |record| record[:id] == id }
  end

  def customers(tier: nil, limit: nil)
    result = CUSTOMERS
    result = result.select { |record| record[:tier] == tier } if tier.present?
    limit.present? ? result.first(limit) : result
  end

  def order(id)
    ORDERS.find { |record| record[:id] == id }
  end

  def orders_for_customer(customer_id, status: nil, limit: nil)
    result = ORDERS.select { |record| record[:customer_id] == customer_id }
    result = result.select { |record| record[:status] == status } if status.present?
    result = result.sort_by { |record| record[:placed_at] }.reverse
    limit.present? ? result.first(limit) : result
  end

  def warehouse(id)
    WAREHOUSES.find { |record| record[:id] == id }
  end

  def warehouses
    WAREHOUSES
  end

  def supplier(id)
    SUPPLIERS.find { |record| record[:id] == id }
  end

  def product(id)
    PRODUCTS.find { |record| record[:id] == id }
  end

  def search_products(query, limit)
    normalized = query.to_s.downcase
    result = PRODUCTS.select do |record|
      record[:name].downcase.include?(normalized) ||
        record[:sku].downcase.include?(normalized) ||
        record[:category].downcase.include?(normalized)
    end
    result.first(limit)
  end

  def inventory_for_product(product_id)
    INVENTORY_SNAPSHOTS.select { |snapshot| snapshot[:product_id] == product_id }
  end

  def inventory_for_warehouse(warehouse_id, product_ids: nil)
    result = INVENTORY_SNAPSHOTS.select { |snapshot| snapshot[:warehouse_id] == warehouse_id }
    result = result.select { |snapshot| product_ids.include?(snapshot[:product_id]) } if product_ids.present?
    result
  end

  def money(cents, currency = "USD")
    {
      amount: (cents.to_f / 100).round(2),
      currency: currency
    }
  end

  def line_item_total_cents(line_item)
    gross = line_item[:unit_price_cents] * line_item[:quantity]
    [gross - line_item[:discount_cents], 0].max
  end

  def order_subtotal_cents(order)
    order[:line_items].sum { |line_item| line_item[:unit_price_cents] * line_item[:quantity] }
  end

  def order_total_cents(order)
    order[:line_items].sum { |line_item| line_item_total_cents(line_item) }
  end

  def customer_total_spend_cents(customer_id)
    orders_for_customer(customer_id).sum { |order| order_total_cents(order) }
  end
end
