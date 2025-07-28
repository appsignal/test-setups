package main

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"time"
	"encoding/json"
	"bytes"

	"github.com/gin-gonic/gin"

	_ "github.com/go-sql-driver/mysql"

	// From our installer
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploghttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/log/global"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	sdklog "go.opentelemetry.io/otel/sdk/log"
	sdkresource "go.opentelemetry.io/otel/sdk/resource"

	// For custom instrumentation
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/metric"
	"go.opentelemetry.io/otel/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.7.0"

	// Additional instrumentation
	"github.com/XSAM/otelsql"
	"go.opentelemetry.io/contrib/bridges/otelslog"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
)

var tracer = otel.Tracer("opentelemetry-go-gin")

func newConsoleExporter() (sdktrace.SpanExporter, error) {
	return stdouttrace.New(
		stdouttrace.WithWriter(os.Stdout),
		stdouttrace.WithPrettyPrint(),
		stdouttrace.WithoutTimestamps(),
	)
}

func initOpenTelemetry() func() {
	// Replace these values with your AppSignal application name, environment
	// and push API key. These are used by the resource attributes configuration below.
	name := os.Getenv("APPSIGNAL_APP_NAME")
	push_api_key := os.Getenv("APPSIGNAL_PUSH_API_KEY")
	environment := os.Getenv("APPSIGNAL_APP_ENV")

	// Set the name of the service that is being monitored. A common choice is the
	// name of the framework used. This is used to group traces and metrics in AppSignal.
	service_name := "Gin"

	// Replace endpoint with the address of your AppSignal collector
	// if it's running on another host.
	endpoint := "appsignal-collector:8099"

	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	resource := sdkresource.NewSchemaless(
		attribute.String("appsignal.config.name", name),
		attribute.String("appsignal.config.environment", environment),
		attribute.String("appsignal.config.push_api_key", push_api_key),
		attribute.String("appsignal.config.revision", "test-setups"),
		attribute.String("appsignal.config.language_integration", "golang"),
		attribute.String("appsignal.config.app_path", os.Getenv("PWD")),
		attribute.String("service.name", service_name),
		attribute.String("host.name", hostname),
		attribute.StringSlice("appsignal.config.filter_function_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_query_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_payload", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_session_data", []string{"password", "token"}),
		// attribute.Bool("appsignal.config.send_function_parameters", false),
	)

	// Tracing
	traceClient := otlptracehttp.NewClient(
		otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint(endpoint),
	)
	traceExporter, err := otlptrace.New(context.Background(), traceClient)
	if err != nil {
		log.Fatalf("creating OTLP trace exporter: %v", err)
	}

	consoleExporter, err := newConsoleExporter()
	if err != nil {
		log.Fatalf("creating OTLP console exporter: %v", err)
	}

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(traceExporter),
		sdktrace.WithBatcher(consoleExporter),
		sdktrace.WithResource(resource),
	)
	otel.SetTracerProvider(tracerProvider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))

	// Metrics
	metricExporter, err := otlpmetrichttp.New(
		context.Background(),
		otlpmetrichttp.WithInsecure(),
		otlpmetrichttp.WithEndpoint(endpoint),
	)
	if err != nil {
		log.Fatalf("creating OTLP metric exporter: %v", err)
	}

	meterProvider := sdkmetric.NewMeterProvider(
		sdkmetric.WithReader(sdkmetric.NewPeriodicReader(metricExporter)),
		sdkmetric.WithResource(resource),
	)
	otel.SetMeterProvider(meterProvider)

	// Logs
	logExporter, err := otlploghttp.New(
		context.Background(),
		otlploghttp.WithInsecure(),
		otlploghttp.WithEndpoint(endpoint),
	)
	if err != nil {
		log.Fatalf("creating OTLP log exporter: %v", err)
	}

	loggerProvider := sdklog.NewLoggerProvider(
		sdklog.WithResource(resource),
		sdklog.WithProcessor(
			sdklog.NewBatchProcessor(logExporter),
		),
	)
	global.SetLoggerProvider(loggerProvider)

	return func() {
		ctx := context.Background()
		if err := tracerProvider.Shutdown(ctx); err != nil {
			log.Println("Error shutting down tracer provider:", err)
		}
		if err := meterProvider.Shutdown(ctx); err != nil {
			log.Println("Error shutting down meter provider:", err)
		}
		if err := loggerProvider.Shutdown(ctx); err != nil {
			log.Println("Error shutting down logger provider:", err)
		}
	}
}

func recordParameters(c *gin.Context) {
	span := trace.SpanFromContext(c.Request.Context())

	// Query parameters
	requestQueryParameters := c.Request.URL.Query()
	attributeQueryParameters := make(map[string]any)
	for k, v := range requestQueryParameters {
		attributeQueryParameters[k] = v
	}

	if len(attributeQueryParameters) > 0 {
		serializedQueryParams, err := json.Marshal(attributeQueryParameters)
		if err == nil {
			span.SetAttributes(attribute.String("appsignal.request.query_parameters", string(serializedQueryParams)))
		}
	}

	// Request body payload
	var serializedBodyPayload string
	var payload map[string]interface{}

	requestBodyPayload, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.Next()
		return
	}
	c.Request.Body = ioutil.NopCloser(bytes.NewBuffer(requestBodyPayload))
	contentType := c.GetHeader("Content-Type")
	if contentType == "application/json" {
		serializedBodyPayload = string(requestBodyPayload)
	} else if contentType == "application/x-www-form-urlencoded" {
		// Parse form-urlencoded body
		values, err := url.ParseQuery(string(requestBodyPayload))
		if err != nil {
			c.Next()
			return
		}

		// Convert form values to a JSON-compatible map
		payload = make(map[string]interface{})
		for key, val := range values {
			if len(val) == 1 {
				payload[key] = val[0]
			} else {
				payload[key] = val
			}
		}
		json, _ := json.Marshal(payload)
		serializedBodyPayload = string(json)
	} else {
		c.Next()
		return
	}
	if len(serializedBodyPayload) > 0 {
		span.SetAttributes(attribute.String("appsignal.request.payload", serializedBodyPayload))
	}
	c.Next()
}

func ReadFile(file string) error {
	dataFile, err := os.ReadFile(file)
	if err != nil {
		return err
	}
	fmt.Println(string(dataFile))
	return nil
}

func main() {
	cleanup := initOpenTelemetry()
	defer cleanup()

	db, err := otelsql.Open(
		"mysql",
		"user:password@tcp(mysql:3306)/mydb",
		otelsql.WithAttributes(semconv.DBSystemMySQL),
	)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	r := gin.New()
	r.Use(otelgin.Middleware("opentelemetry-go-gin"))
	r.Use(recordParameters)
	r.LoadHTMLFiles("index.html")

	r.GET("/file-error", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)

		span := trace.SpanFromContext(c.Request.Context())
		err = ReadFile("potato")
		if err != nil {
			// Record the error in OpenTelemetry with stacktrace
			span.RecordError(err, trace.WithStackTrace(true))
			span.SetStatus(codes.Error, err.Error())

			// Also log the error
			logger := otelslog.NewLogger("file-error")
			logger.Error("File read error", "error", err.Error())

			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "File not found",
				"message": err.Error(),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "File read successfully",
		})
	})

	r.GET("/error", func(c *gin.Context) {
		span := trace.SpanFromContext(c.Request.Context())

		// Create a test error
		testErr := errors.New("expected test error")

		// Record the error in OpenTelemetry with stacktrace
		span.RecordError(testErr, trace.WithStackTrace(true))
		span.SetStatus(codes.Error, testErr.Error())

		// Also log the error
		logger := otelslog.NewLogger("error-endpoint")
		logger.Error("Test error occurred", "error", testErr.Error())

		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "expected test error",
			"error": testErr.Error(),
		})
	})

	r.GET("/", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)

		span := trace.SpanFromContext(c.Request.Context())

		functionParams := map[string]interface{}{
			"password": "super secret",
			"test_function_param": "test value",
			"nested": map[string]interface{}{
				"password": "super secret",
				"test_function_param": "test value",
			},
		}
		span.SetAttributes(attribute.String("appsignal.function.parameters", mapToJSON(functionParams)))

		queryParams := map[string]interface{}{
			"password": "super secret",
			"test_query": "test value",
			"nested": map[string]interface{}{
				"password": "super secret",
				"test_query": "test value",
			},
		}
		span.SetAttributes(attribute.String("appsignal.request.query_parameters", mapToJSON(queryParams)))

		payloadData := map[string]interface{}{
			"password": "super secret",
			"test_payload": "test value",
			"nested": map[string]interface{}{
				"password": "super secret",
				"test_payload": "test value",
			},
		}
		span.SetAttributes(attribute.String("appsignal.request.payload", mapToJSON(payloadData)))

		sessionData := map[string]interface{}{
			"password": "super secret",
			"test_payload": "test value",
			"nested": map[string]interface{}{
				"password": "super secret",
				"test_payload": "test value",
			},
		}
		span.SetAttributes(attribute.String("appsignal.request.session_data", mapToJSON(sessionData)))

		span.SetAttributes(attribute.StringSlice("http.response.header.custom-header", []string{"abc", "def"}))

		// Tags
		span.SetAttributes(attribute.String("appsignal.tag.tag_string", "tag value"))
		span.SetAttributes(attribute.StringSlice("appsignal.tag.tag_int64", []string{"abc", "def"}))
		span.SetAttributes(attribute.Bool("appsignal.tag.tag_bool_true", true))
		span.SetAttributes(attribute.Bool("appsignal.tag.tag_bool_false", false))
		span.SetAttributes(attribute.BoolSlice("appsignal.tag.tag_bool_slice", []bool{true, false}))
		span.SetAttributes(attribute.Float64("appsignal.tag.tag_float64", 12.34))
		span.SetAttributes(attribute.Float64Slice("appsignal.tag.tag_float64_slice", []float64{12.34, 56.78}))
		span.SetAttributes(attribute.Int("appsignal.tag.tag_int", 1234))
		span.SetAttributes(attribute.IntSlice("appsignal.tag.tag_int", []int{1234, 5678}))
		span.SetAttributes(attribute.Int64("appsignal.tag.tag_int64", 1234))
		span.SetAttributes(attribute.Int64Slice("appsignal.tag.tag_int64_slice", []int64{1234, 5678}))

		c.HTML(http.StatusOK, "index.html", gin.H{})
	})

	r.GET("/slow", func(c *gin.Context) {
		time.Sleep(3 * time.Second)

		c.JSON(http.StatusOK, gin.H{
			"message": "Well, that took forever!",
		})
	})

	r.GET("/logs", func(c *gin.Context) {
		logger := otelslog.NewLogger("some-name")
		logger.Info("This is an info message")
		logger.Error("This is an error message")
		logger.Info("This is an info message with a tag", "tag", "value")

		c.JSON(http.StatusOK, gin.H{
			"message": "Logs were sent",
		})
	})

	r.POST("/post-test", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)
		bodyParams, err := ioutil.ReadAll(c.Request.Body)
		if err != nil {
			panic(err)
		}

		c.JSON(http.StatusOK, string(bodyParams))
	})

	r.GET("/metrics", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)

		var meter = otel.Meter("example.io/package/name")
		ctx := c.Request.Context()

		// Counter metric
		myCounter, err := meter.Int64Counter(
			"my_counter",
			metric.WithDescription("My counter"),
			metric.WithUnit("1"),
		)
		if err != nil {
			panic(err)
		}
		myCounter.Add(
			ctx,
			int64(rand.Intn(25) + 3), // Value between 1 and 3
			metric.WithAttributes(attribute.String("my_tag", "tag_value")),
		)

		// Gauge
		myGauge, err := meter.Int64Gauge(
			"my_guage",
			metric.WithDescription("My gauge"),
			metric.WithUnit("1"),
		)
		if err != nil {
			panic(err)
		}
		myGauge.Record(
			ctx,
			int64(rand.Intn(25) + 10), // Value between 1 and 25
			metric.WithAttributes(attribute.String("my_tag", "tag_value")),
		)

		// Histogram
		myHistogram, err := meter.Float64Histogram(
			"my_histogram",
			metric.WithDescription("My Histogram"),
			metric.WithUnit("1"),
		)
		myHistogram.Record(
			ctx,
			float64(rand.Intn(16) + 10), // Value between 10 and 25
			metric.WithAttributes(attribute.String("my_tag", "tag_value")),
		)

		response := map[string]interface{}{
			"message": "Metrics were sent",
		}
		c.JSON(http.StatusOK, response)
	})

	r.GET("/mysql-query", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)

		_, err := db.QueryContext(c.Request.Context(), "SELECT 1 + 1 AS solution")
		if err != nil {
			panic(err)
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "Launched MySQL QUERY",
		})
	})
	r.Run(":4001")
}

func mapToJSON(m map[string]interface{}) string {
	jsonBytes, err := json.Marshal(m)
	if err != nil {
		return "{}" // Return empty JSON object on error
	}
	return string(jsonBytes)
}
