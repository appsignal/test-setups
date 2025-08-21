package io.opentelemetry.example.graal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import java.util.Random;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.DoubleCounter;
import io.opentelemetry.api.metrics.DoubleGauge;
import io.opentelemetry.api.metrics.DoubleHistogram;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.common.AttributeKey;

@RestController
public class WebshopController {
    private final Random random = new Random();
    private static final Logger logger = LogManager.getLogger(WebshopController.class);
    private final Meter meter = GlobalOpenTelemetry.getMeter("webshop-controller");
    
    // Define metrics
    private final LongCounter checkoutCounter = meter
        .counterBuilder("checkout_total")
        .setDescription("Total number of checkout attempts")
        .setUnit("1")
        .build();
        
    private final DoubleCounter revenueCounter = meter
        .counterBuilder("checkout_revenue")
        .ofDoubles()
        .setDescription("Total revenue from checkouts")
        .setUnit("USD")
        .build();
        
    private final LongCounter itemsCounter = meter
        .counterBuilder("checkout_items")
        .setDescription("Total items checked out")
        .setUnit("1")
        .build();
        
    private final DoubleGauge inventoryGauge = meter
        .gaugeBuilder("inventory_remaining")
        .setDescription("Remaining inventory levels")
        .setUnit("1")
        .build();
        
    private final DoubleHistogram orderValueHistogram = meter
        .histogramBuilder("order_value")
        .setDescription("Distribution of order values")
        .setUnit("USD")
        .build();
    
    // Custom exception classes
    public static class ProductNotFoundException extends RuntimeException {
        public ProductNotFoundException(String message) {
            super(message);
        }
    }
    
    public static class InsufficientInventoryException extends RuntimeException {
        public InsufficientInventoryException(String message) {
            super(message);
        }
    }
    
    public static class PaymentProcessingException extends RuntimeException {
        public PaymentProcessingException(String message) {
            super(message);
        }
    }
    
    public static class UserAuthenticationException extends RuntimeException {
        public UserAuthenticationException(String message) {
            super(message);
        }
    }
    
    public static class CartEmptyException extends RuntimeException {
        public CartEmptyException(String message) {
            super(message);
        }
    }

    @GetMapping("/checkout")
    public String checkout() throws InterruptedException {
      Random random = new Random();
      Tracer tracer = GlobalOpenTelemetry.getTracer("my-app");
      
      // Generate dynamic values
      int customerId = 1000 + random.nextInt(9000);
      double totalAmount = 25.99 + (random.nextDouble() * 300);
      String[] currencies = {"USD", "EUR"};
      String currency = currencies[random.nextInt(currencies.length)];
      int itemsCount = 1 + random.nextInt(8);
      String orderId = "order_" + (100000 + random.nextInt(900000));
      
      // Main checkout span
      Span checkoutSpan = tracer.spanBuilder("checkout.process").startSpan();
      try (Scope checkoutScope = checkoutSpan.makeCurrent()) {
        checkoutSpan.setAttribute("checkout.customer_id", "customer_" + customerId);
        checkoutSpan.setAttribute("checkout.total_amount", Math.round(totalAmount * 100.0) / 100.0);
        checkoutSpan.setAttribute("checkout.currency", currency);
        
        String[] checkoutStatuses = {"completed", "completed", "completed", "failed", "pending"};
        checkoutSpan.setAttribute("checkout.status", checkoutStatuses[random.nextInt(checkoutStatuses.length)]);
      } finally {
        checkoutSpan.end();
      }
      
      // PostgreSQL database query span  
      Tracer postgresqlTracer = GlobalOpenTelemetry.getTracer("postgresql");
      Span postgresqlSpan = postgresqlTracer.spanBuilder("postgresql SELECT").startSpan();
      try (Scope postgresqlScope = postgresqlSpan.makeCurrent()) {
        Thread.sleep(50 + random.nextInt(80));
        postgresqlSpan.setAttribute("db.system", "postgresql");
        postgresqlSpan.setAttribute("db.statement", "SELECT * FROM orders WHERE customer_id = ? AND status = 'active'");
        postgresqlSpan.setAttribute("db.name", "ecommerce");
        postgresqlSpan.setAttribute("db.table", "orders");
        postgresqlSpan.setAttribute("db.rows_affected", random.nextInt(10));
      } finally {
        postgresqlSpan.end();
      }
      
      // Redis cache query span
      Tracer redisTracer = GlobalOpenTelemetry.getTracer("redis");
      Span redisSpan = redisTracer.spanBuilder("redis GET").startSpan();
      try (Scope redisScope = redisSpan.makeCurrent()) {
        Thread.sleep(5 + random.nextInt(15));
        redisSpan.setAttribute("db.system", "redis");
        redisSpan.setAttribute("db.statement", "GET ? ? ?");
        redisSpan.setAttribute("db.redis.key", "user:session:" + customerId);
        redisSpan.setAttribute("db.response_size", 128 + random.nextInt(512));
      } finally {
        redisSpan.end();
      }
        
      // Cart validation span
      Span cartValidationSpan = tracer.spanBuilder("checkout.validate_cart").startSpan();
      try (Scope cartScope = cartValidationSpan.makeCurrent()) {
        Thread.sleep(30 + random.nextInt(40));
        cartValidationSpan.setAttribute("cart.items_count", itemsCount);
        String[] validationStatuses = {"valid", "valid", "valid", "warning"};
        cartValidationSpan.setAttribute("cart.validation_status", validationStatuses[random.nextInt(validationStatuses.length)]);
      } finally {
        cartValidationSpan.end();
      }
      
      // Inventory check span
      Span inventorySpan = tracer.spanBuilder("checkout.check_inventory").startSpan();
      try (Scope inventoryScope = inventorySpan.makeCurrent()) {
        Thread.sleep(50 + random.nextInt(100));
        String[] checkTypes = {"real_time", "cached", "batch"};
        inventorySpan.setAttribute("inventory.check_type", checkTypes[random.nextInt(checkTypes.length)]);
        inventorySpan.setAttribute("inventory.all_available", random.nextBoolean() || random.nextBoolean());
      } finally {
        inventorySpan.end();
      }
      
      // Payment processing span
      String[] paymentMethods = {"credit_card", "debit_card"};
      String[] processors = {"stripe", "paypal", "square", "braintree"};
      String selectedPaymentMethod = paymentMethods[random.nextInt(paymentMethods.length)];
      String selectedProcessor = processors[random.nextInt(processors.length)];
      
      Span paymentSpan = tracer.spanBuilder("checkout.process_payment").startSpan();
      try (Scope paymentScope = paymentSpan.makeCurrent()) {
        paymentSpan.setAttribute("payment.method", selectedPaymentMethod);
        paymentSpan.setAttribute("payment.processor", selectedProcessor);
      } finally {
        paymentSpan.end();
      }
        
      // Payment validation sub-span
      String[] cardTypes = {"visa", "mastercard", "amex", "discover"};
      String[] validationResults = {"approved", "approved", "approved", "declined", "requires_auth"};
      String selectedCardType = cardTypes[random.nextInt(cardTypes.length)];
      String validationResult = validationResults[random.nextInt(validationResults.length)];
      
      Span paymentValidationSpan = tracer.spanBuilder("payment.validate_card").startSpan();
      try (Scope paymentValidationScope = paymentValidationSpan.makeCurrent()) {
        Thread.sleep(40 + random.nextInt(70));
        paymentValidationSpan.setAttribute("payment.card_type", selectedCardType);
        paymentValidationSpan.setAttribute("payment.validation_result", validationResult);
      } finally {
        paymentValidationSpan.end();
      }

      // PostgreSQL database query span  
      Span postgresqlSpan2 = postgresqlTracer.spanBuilder("postgresql INSERT").startSpan();
      try (Scope postgresqlScope = postgresqlSpan2.makeCurrent()) {
        Thread.sleep(50 + random.nextInt(80));
        postgresqlSpan2.setAttribute("db.system", "postgresql");
        postgresqlSpan2.setAttribute("db.statement", "INSERT INTO orders (customer_id, cart_id) VALUES (?, ?)");
        postgresqlSpan2.setAttribute("db.name", "ecommerce");
        postgresqlSpan2.setAttribute("db.table", "orders");
        postgresqlSpan2.setAttribute("db.rows_affected", random.nextInt(10));
      } finally {
        postgresqlSpan2.end();
      }
      
      // Charge processing sub-span
      Span chargeSpan = tracer.spanBuilder("payment.charge").startSpan();
      try (Scope chargeScope = chargeSpan.makeCurrent()) {
        Thread.sleep(100 + random.nextInt(200));
        String transactionId = "txn_" + Long.toHexString(System.currentTimeMillis()) + Integer.toHexString(random.nextInt(65536));
        chargeSpan.setAttribute("payment.transaction_id", transactionId);
        chargeSpan.setAttribute("payment.amount_charged", Math.round(totalAmount * 100.0) / 100.0);
        String[] paymentStatuses = {"succeeded", "succeeded", "succeeded", "failed", "pending"};
        chargeSpan.setAttribute("payment.status", paymentStatuses[random.nextInt(paymentStatuses.length)]);
      } finally {
        chargeSpan.end();
      }
      
      // Order creation span
      Span orderSpan = tracer.spanBuilder("checkout.create_order").startSpan();
      try (Scope orderScope = orderSpan.makeCurrent()) {
        Thread.sleep(60 + random.nextInt(40));
        orderSpan.setAttribute("order.id", orderId);
        String[] orderStatuses = {"confirmed", "confirmed", "pending", "processing"};
        orderSpan.setAttribute("order.status", orderStatuses[random.nextInt(orderStatuses.length)]);
        
        String[] skus = {"SHOE123", "SHIRT456", "PANTS789", "JACKET012", "HAT345", "BELT678"};
        StringBuilder items = new StringBuilder("[");
        for (int i = 0; i < itemsCount && i < 3; i++) {
          if (i > 0) items.append(",");
          String sku = skus[random.nextInt(skus.length)];
          int qty = 1 + random.nextInt(3);
          items.append("{\"sku\":\"").append(sku).append("\",\"qty\":").append(qty).append("}");
        }
        items.append("]");
        orderSpan.setAttribute("order.items", items.toString());
      } finally {
        orderSpan.end();
      }
      
      // Shipping calculation span
      Span shippingSpan = tracer.spanBuilder("checkout.calculate_shipping").startSpan();
      try (Scope shippingScope = shippingSpan.makeCurrent()) {
        Thread.sleep(40 + random.nextInt(50));
        String[] shippingMethods = {"standard", "express", "overnight", "economy"};
        String[] carriers = {"FedEx", "UPS", "USPS", "DHL", "Amazon"};
        shippingSpan.setAttribute("shipping.method", shippingMethods[random.nextInt(shippingMethods.length)]);
        shippingSpan.setAttribute("shipping.cost", Math.round((5.99 + random.nextDouble() * 20) * 100.0) / 100.0);
        shippingSpan.setAttribute("shipping.estimated_days", 1 + random.nextInt(7));
        shippingSpan.setAttribute("shipping.carrier", carriers[random.nextInt(carriers.length)]);
      } finally {
        shippingSpan.end();
      }
      
      // Email notification span
      Span emailSpan = tracer.spanBuilder("checkout.send_confirmation_email").startSpan();
      try (Scope emailScope = emailSpan.makeCurrent()) {
        Thread.sleep(60 + random.nextInt(60));
        String[] emailTemplates = {"order_confirmation", "order_receipt", "purchase_summary"};
        String[] emailStatuses = {"sent", "sent", "sent", "failed", "queued"};
        String[] domains = {"example.com", "gmail.com", "yahoo.com", "hotmail.com", "company.com"};
        emailSpan.setAttribute("email.template", emailTemplates[random.nextInt(emailTemplates.length)]);
        emailSpan.setAttribute("email.recipient", "customer" + customerId + "@" + domains[random.nextInt(domains.length)]);
        emailSpan.setAttribute("email.status", emailStatuses[random.nextInt(emailStatuses.length)]);
      } finally {
        emailSpan.end();
      }
      
      // Memcached query span
      Tracer memcachedTracer = GlobalOpenTelemetry.getTracer("memcached");
      Span memcachedSpan = memcachedTracer.spanBuilder("memcached store").startSpan();
      try (Scope memcachedScope = memcachedSpan.makeCurrent()) {
        Thread.sleep(3 + random.nextInt(12));
        memcachedSpan.setAttribute("appsignal.scope", "memcached");
        memcachedSpan.setAttribute("db.system", "memcached");
        memcachedSpan.setAttribute("db.operation", "GET");
        memcachedSpan.setAttribute("db.memcached.key", "product:inventory:" + (1000 + random.nextInt(5000)));
        String[] cacheStatuses = {"hit", "hit", "hit", "miss"};
        memcachedSpan.setAttribute("cache.status", cacheStatuses[random.nextInt(cacheStatuses.length)]);
      } finally {
        memcachedSpan.end();
      }

      // Render span
      Tracer renderTracer = GlobalOpenTelemetry.getTracer("render");
      Span renderSpan = renderTracer.spanBuilder("render success.html").startSpan();
      try (Scope renderScope = renderSpan.makeCurrent()) {
        Thread.sleep(3 + random.nextInt(12));
        
        renderSpan.setAttribute("appsignal.scope", "render");
        renderSpan.setAttribute("view.path", "resources/templates/success.html");
      } finally {
        renderSpan.end();
      }
      
      // Record checkout metrics
      recordCheckoutMetrics(itemsCount, totalAmount, currency, selectedPaymentMethod, selectedCardType);

      return "Checkout completed successfully! Order #" + orderId + " has been processed.";
    }
    
    private void randomSleep() throws InterruptedException {
        Thread.sleep(50 + random.nextInt(200));
    }
    
    private void recordCheckoutMetrics(int itemsCount, double totalAmount, String currency, 
                                     String paymentMethod, String cardType) {
        // Increment checkout counter
        checkoutCounter.add(1, Attributes.of(
            AttributeKey.stringKey("currency"), currency,
            AttributeKey.stringKey("payment_method"), paymentMethod,
            AttributeKey.stringKey("card_type"), cardType
        ));
        
        // Record revenue
        revenueCounter.add(totalAmount, Attributes.of(
            AttributeKey.stringKey("currency"), currency,
            AttributeKey.stringKey("payment_method"), paymentMethod
        ));
        
        // Record items count
        itemsCounter.add(itemsCount, Attributes.of(
            AttributeKey.stringKey("currency"), currency
        ));
        
        // Record order value histogram
        orderValueHistogram.record(totalAmount, Attributes.of(
            AttributeKey.stringKey("currency"), currency,
            AttributeKey.stringKey("payment_method"), paymentMethod
        ));
        
        // Update inventory gauge (simulate remaining inventory)
        double remainingInventory = 1000 + random.nextDouble() * 5000;
        inventoryGauge.set(remainingInventory, Attributes.of(
            AttributeKey.stringKey("warehouse"), "main",
            AttributeKey.stringKey("product_category"), getRandomProductCategory()
        ));
        
        // Record additional business metrics
        recordAdditionalMetrics(paymentMethod, cardType, itemsCount);
    }
    
    private void recordAdditionalMetrics(String paymentMethod, String cardType, int itemsCount) {
        // Cart abandonment rate (simulate)
        LongCounter cartAbandonmentCounter = meter
            .counterBuilder("cart_abandonment")
            .setDescription("Cart abandonment events")
            .setUnit("1")
            .build();
            
        if (random.nextInt(10) == 0) { // 10% abandonment rate
            cartAbandonmentCounter.add(1);
        }
        
        // Customer satisfaction score (simulate)
        DoubleGauge satisfactionGauge = meter
            .gaugeBuilder("customer_satisfaction")
            .setDescription("Customer satisfaction score")
            .setUnit("1")
            .build();
            
        double satisfactionScore = 60 + random.nextDouble() * 34; // 60-94 score
        satisfactionGauge.set(satisfactionScore);
        
        // Fraud detection score
        DoubleHistogram fraudScoreHistogram = meter
            .histogramBuilder("fraud_detection_score")
            .setDescription("Fraud detection scores")
            .setUnit("1")
            .build();
            
        double fraudScore = random.nextDouble() * 100; // 0-100 score
        fraudScoreHistogram.record(fraudScore, Attributes.of(
            AttributeKey.stringKey("payment_method"), paymentMethod,
            AttributeKey.stringKey("risk_level"), getFraudRiskLevel(fraudScore)
        ));
        
        // Page load times
        DoubleHistogram pageLoadHistogram = meter
            .histogramBuilder("page_load_time")
            .setDescription("Page load times")
            .setUnit("ms")
            .build();
            
        double pageLoadTime = 200 + random.nextDouble() * 800; // 200-1000ms
        pageLoadHistogram.record(pageLoadTime, Attributes.of(
            AttributeKey.stringKey("page"), "checkout",
            AttributeKey.stringKey("user_type"), random.nextBoolean() ? "premium" : "standard"
        ));
    }
    
    private String getRandomProductCategory() {
        String[] categories = {"electronics", "clothing", "books", "home", "sports", "beauty"};
        return categories[random.nextInt(categories.length)];
    }
    
    private String getOrderSizeCategory(int itemsCount) {
        if (itemsCount <= 2) return "small";
        if (itemsCount <= 5) return "medium";
        return "large";
    }
    
    private String getFraudRiskLevel(double score) {
        if (score < 30) return "low";
        if (score < 70) return "medium";
        return "high";
    }
    
    private void logMessage() {
        String[] logMessages = {
            "User session validated successfully",
            "Cache hit for product catalog data",
            "Database query executed in {}ms",
            "External API call to payment processor completed",
            "Inventory levels synchronized from warehouse",
            "Database connection pool exhausted - retrying",
            "Search index updated with new product data",
            "Email notification queued for processing",
            "Shopping cart items validated against current prices",
            "Security token refresh completed",
            "High CPU usage detected on payment service",
            "Product recommendations generated for user segment",
            "Audit log entry created for user action",
            "CDN cache invalidated for updated product images",
            "Background job scheduled for inventory restock",
            "Vulnerability bot scan detected",
            "Third-party integration health check passed",
            "Third-party integration health check failed",
            "Session timeout warning sent to client",
            "Promotional pricing rules applied to cart",
            "Shipping calculator service response timeout",
            "Customer support ticket auto-categorized",
            "Failed login attempt detected - possible brute force",
            "Geographic location detected for shipping estimates",
            "Fraud detection scan completed - low risk score",
            "Product availability service temporarily unavailable",
            "Marketing campaign attribution tracked",
            "Customer loyalty points balance updated",
            "Cross-sell recommendations filtered by preferences",
            "Order processing workflow initiated",
            "Payment gateway returning elevated error rates",
            "Wishlist synchronization across devices completed"
        };
        
        String[] logLevels = {"info", "debug", "warn"};
        String level = logLevels[random.nextInt(logLevels.length)];
        String message = logMessages[random.nextInt(logMessages.length)];
        
        // Add some dynamic values to make logs more realistic
        if (message.contains("{}")) {
            message = message.replace("{}", String.valueOf(50 + random.nextInt(500)));
        }
        
        switch (level) {
            case "info":
                logger.info(message);
                break;
            case "debug":
                logger.debug(message + " [RequestID: " + generateRequestId() + "]");
                break;
            case "warn":
                logger.warn(message + " [Performance threshold exceeded]");
                break;
        }
    }
    
    private String generateRequestId() {
        return "req_" + System.currentTimeMillis() % 100000 + "_" + random.nextInt(9999);
    }
    
    private void maybeThrowProductsError() {
        if (random.nextInt(10) < 4) { // 40% error rate
            int productId = 1000 + random.nextInt(9000);
            throw new ProductNotFoundException("Product with ID " + productId + " not found in catalog");
        }
    }
    
    private void maybeThrowError() throws Exception {
        if (random.nextInt(100) == 0) {
            String[] errorMessages = {
                "Database connection timeout",
                "Service temporarily unavailable",
                "Invalid request parameters",
                "External API failure",
                "Cache miss - data not found"
            };
            
            int errorType = random.nextInt(12);
            switch (errorType) {
                case 0:
                    throw new ProductNotFoundException("Product with ID " + (1000 + random.nextInt(9000)) + " not found");
                case 1:
                    throw new InsufficientInventoryException("Only " + random.nextInt(5) + " items left in stock");
                case 2:
                    throw new PaymentProcessingException("Payment gateway returned error code " + (400 + random.nextInt(100)));
                case 3:
                    throw new UserAuthenticationException("Session expired - please log in again");
                case 4:
                    throw new CartEmptyException("Cannot proceed with empty shopping cart");
                case 5:
                    throw new IllegalArgumentException("Invalid product ID format: " + random.nextInt(100000));
                case 6:
                    throw new IllegalStateException("User account is locked or suspended");
                case 7:
                    throw new NullPointerException("Required field 'email' is null");
                case 8:
                    throw new NumberFormatException("Invalid price format: $" + (random.nextDouble() * 1000));
                case 9:
                    throw new SecurityException("Access denied - insufficient permissions");
                case 10:
                    throw new RuntimeException(errorMessages[random.nextInt(errorMessages.length)]);
                default:
                    throw new Exception("Unexpected system error - contact support");
            }
        }
    }
    
    // Product Management endpoints
    @GetMapping("/products")
    public String products() throws Exception {
        logMessage();
        
        Tracer tracer = GlobalOpenTelemetry.getTracer("products-service");
        
        // Cache lookup span
        Span cacheSpan = tracer.spanBuilder("products.cache_lookup").startSpan();
        try (Scope cacheScope = cacheSpan.makeCurrent()) {
            Thread.sleep(5 + random.nextInt(10));
            cacheSpan.setAttribute("cache.type", "redis");
            cacheSpan.setAttribute("cache.key", "products:catalog:page_1");
            String[] cacheResults = {"hit", "hit", "hit", "miss"};
            cacheSpan.setAttribute("cache.result", cacheResults[random.nextInt(cacheResults.length)]);
        } finally {
            cacheSpan.end();
        }
        
        // Database query span
        Span dbSpan = tracer.spanBuilder("products.fetch_catalog").startSpan();
        try (Scope dbScope = dbSpan.makeCurrent()) {
            Thread.sleep(20 + random.nextInt(60));
            dbSpan.setAttribute("db.system", "postgresql");
            dbSpan.setAttribute("db.statement", "SELECT * FROM products WHERE active = ? ORDER BY created_at DESC LIMIT ?");
            dbSpan.setAttribute("db.name", "ecommerce");
            dbSpan.setAttribute("db.table", "products");
            dbSpan.setAttribute("db.rows_returned", 20 + random.nextInt(30));
        } finally {
            dbSpan.end();
        }
        
        // Image processing span
        Span imageSpan = tracer.spanBuilder("products.process_images").startSpan();
        try (Scope imageScope = imageSpan.makeCurrent()) {
            Thread.sleep(15 + random.nextInt(25));
            imageSpan.setAttribute("image.processor", "thumbnails");
            imageSpan.setAttribute("image.count", 5 + random.nextInt(15));
            imageSpan.setAttribute("image.format", "webp");
            imageSpan.setAttribute("image.quality", "medium");
        } finally {
            imageSpan.end();
        }
        
        randomSleep();

        // Render span
        Tracer renderTracer = GlobalOpenTelemetry.getTracer("render");
        Span renderSpan = tracer.spanBuilder("render error.html").startSpan();
        try (Scope renderScope = renderSpan.makeCurrent()) {
          Thread.sleep(3 + random.nextInt(12));
          
          renderSpan.setAttribute("appsignal.scope", "render");
          renderSpan.setAttribute("view.path", "resources/templates/error.html");
        } finally {
          renderSpan.end();
        }

        maybeThrowProductsError();
        return "Demo!";
    }
    
    @GetMapping("/products/{id}")
    public String productDetails(@PathVariable String id) throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/products/search")
    public String productSearch() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/categories")
    public String categories() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/categories/{id}/products")
    public String categoryProducts(@PathVariable String id) throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    // Shopping Cart endpoints
    @GetMapping("/cart")
    public String viewCart() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @PostMapping("/cart/add")
    public String addToCart() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @DeleteMapping("/cart/remove")
    public String removeFromCart() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @PutMapping("/cart/update")
    public String updateCart() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    // User Account endpoints
    @PostMapping("/login")
    public String login() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @PostMapping("/register")
    public String register() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/account")
    public String account() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/account/profile")
    public String accountProfile() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/account/orders")
    public String accountOrders() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/account/addresses")
    public String accountAddresses() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/account/wishlist")
    public String accountWishlist() throws Exception {
        logMessage();
        maybeThrowError();
        randomSleep();
        return "Demo!";
    }
    
    // Support endpoints
    @GetMapping("/help")
    public String help() throws InterruptedException {
        logMessage();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/contact")
    public String contact() throws InterruptedException {
        logMessage();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/returns")
    public String returns() throws InterruptedException {
        logMessage();
        randomSleep();
        return "Demo!";
    }
    
    @GetMapping("/shipping")
    public String shipping() throws InterruptedException {
        logMessage();
        randomSleep();
        return "Demo!";
    }
}
