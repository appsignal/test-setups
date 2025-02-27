package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"time"
	"encoding/json"
	"bytes"

	"github.com/gin-gonic/gin"

	_ "github.com/go-sql-driver/mysql"

	"github.com/XSAM/otelsql"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/trace"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.7.0"
)

var tracer = otel.Tracer("opentelemetry-go-gin")

func newConsoleExporter() (sdktrace.SpanExporter, error) {
	return stdouttrace.New(
		stdouttrace.WithWriter(os.Stdout),
		stdouttrace.WithPrettyPrint(),
		stdouttrace.WithoutTimestamps(),
	)
}

func initTracer() func(context.Context) error {
	client := otlptracehttp.NewClient(
		otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint("appsignal-collector:8099"),
	)
	exporter, err := otlptrace.New(context.Background(), client)
	if err != nil {
		log.Fatal("creating OTLP trace exporter: %w")
	}

	consoleExporter, err := newConsoleExporter()
	if err != nil {
		log.Fatal("creating OTLP console exporter: %w")
	}

	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	resource := resource.NewSchemaless(
		attribute.String("appsignal.config.name", os.Getenv("APPSIGNAL_APP_NAME")),
		attribute.String("appsignal.config.environment", os.Getenv("APPSIGNAL_APP_ENV")),
		attribute.String("appsignal.config.push_api_key", os.Getenv("APPSIGNAL_PUSH_API_KEY")),
		attribute.String("appsignal.config.revision", "test-setups"),
		attribute.String("appsignal.config.language_integration", "golang"),
		attribute.String("appsignal.config.app_path", os.Getenv("PWD")),
		attribute.String("service.name", "Gin"),
		attribute.String("host.name", hostname),
		attribute.StringSlice("appsignal.config.filter_function_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_query_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_payload", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_session_data", []string{"password", "token"}),
		// attribute.Bool("appsignal.config.send_function_parameters", false),
	)

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithBatcher(consoleExporter),
		sdktrace.WithResource(resource),
	)
	otel.SetTracerProvider(tracerProvider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
	return exporter.Shutdown
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
	cleanup := initTracer()
	defer cleanup(context.Background())

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

		err = ReadFile("potato")
		if err != nil {
			log.Fatal(err)
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"unreachable": "response",
		})
	})

	r.GET("/error", func(c *gin.Context) {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "expected test error",
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

		c.HTML(http.StatusOK, "index.html", gin.H{})
	})

	r.GET("/slow", func(c *gin.Context) {
		time.Sleep(3 * time.Second)

		c.JSON(http.StatusOK, gin.H{
			"message": "Well, that took forever!",
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
