package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

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

	res := resource.NewSchemaless(
		attribute.String("appsignal.config.name", os.Getenv("APPSIGNAL_APP_NAME")),
		attribute.String("appsignal.config.environment", os.Getenv("APPSIGNAL_APP_ENV")),
		attribute.String("appsignal.config.push_api_key", os.Getenv("APPSIGNAL_PUSH_API_KEY")),
		attribute.String("appsignal.config.revision", "abcd123"),
		attribute.String("appsignal.config.language_integration", "golang"),
		attribute.String("appsignal.config.app_path", os.Getenv("PWD")),
		attribute.String("service.name", "Gin"),
		attribute.String("host.name", hostname),
	)

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithBatcher(consoleExporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tracerProvider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
	return exporter.Shutdown
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

		c.JSON(http.StatusOK, gin.H{
			"message": "ping",
		})
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

		c.JSON(http.StatusOK, bodyParams)
	})

	r.GET("/mysql-query", func(c *gin.Context) {
		time.Sleep(200 * time.Millisecond)

		_, err := db.QueryContext(c, "SELECT 1 + 1 AS solution")
		if err != nil {
			panic(err)
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "Launched MySQL QUERY",
		})
	})
	r.Run(":4001")
}
