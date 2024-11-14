// main.go
package main

import (
	"context"
	"log"
	"time"
	"os"

	"github.com/beego/beego/v2/server/web"
	beecontext "github.com/beego/beego/v2/server/web/context"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
)

var tracer = otel.Tracer("beego-app")

func initTracer() func() {
	exporter, err := otlptracehttp.New(
		context.Background(),
		otlptracehttp.WithEndpoint("appsignal:8099"),
		otlptracehttp.WithURLPath("/enriched/v1/traces"),
		otlptracehttp.WithInsecure(),
	)
	if err != nil {
		log.Fatal(err)
	}

	app_name := os.Getenv("APPSIGNAL_APP_NAME")
	if app_name == "" {
		panic("No APPSIGNAL_APP_NAME env var");
	}
	app_env := os.Getenv("APPSIGNAL_APP_ENV")
	if app_env == "" {
		panic("No APPSIGNAL_APP_ENV env var");
	}
	push_api_key := os.Getenv("APPSIGNAL_PUSH_API_KEY")
	if push_api_key == "" {
		panic("No APPSIGNAL_PUSH_API_KEY env var");
	}

	res, err := resource.Merge(
		resource.Default(),
		resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceName("beego-mod-otel"),
			attribute.String("appsignal.config.app_name", app_name),
			attribute.String("appsignal.config.app_environment", app_env),
			attribute.String("appsignal.config.push_api_key", push_api_key),
			attribute.String("appsignal.config.language_integration", "go"),
		),
	)
	if err != nil {
		log.Fatal(err)
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tp)

	return func() {
		if err := tp.Shutdown(context.Background()); err != nil {
			log.Printf("Error shutting down tracer provider: %v", err)
		}
	}
}

type MainController struct {
	web.Controller
}

func (c *MainController) Get() {
	_, span := tracer.Start(context.Background(), "home-handler")
	defer span.End()
	c.Ctx.Output.SetStatus(200)
	c.Data["json"] = map[string]string{"message": "Welcome to the home page"}
	c.ServeJSON()
}

func (c *MainController) Hello() {
	_, span := tracer.Start(context.Background(), "hello-handler")
	defer span.End()
	c.Ctx.Output.SetStatus(200)
	c.Data["json"] = map[string]string{"message": "Hello, World!"}
	c.ServeJSON()
}

func (c *MainController) Slow() {
	ctx, span := tracer.Start(context.Background(), "slow-handler")
	defer span.End()

	_, delaySpan := tracer.Start(ctx, "delay")
	time.Sleep(3 * time.Second)
	delaySpan.End()

	c.Ctx.Output.SetStatus(200)
	c.Data["json"] = map[string]string{"message": "Slow response after 3 seconds"}
	c.ServeJSON()
}

func (c *MainController) Error() {
	_, span := tracer.Start(context.Background(), "error-handler")
	defer span.End()
	c.Ctx.Output.SetStatus(500)
	c.Data["json"] = map[string]string{"error": "Internal Server Error"}
	c.ServeJSON()
}

func main() {
	cleanup := initTracer()
	defer cleanup()

	web.InsertFilter("*", web.BeforeRouter, func(ctx *beecontext.Context) {
		req := ctx.Request
		ctx.Request = req.WithContext(context.Background())
	})

	web.Router("/", &MainController{})
	web.Router("/hello", &MainController{}, "get:Hello")
	web.Router("/slow", &MainController{}, "get:Slow")
	web.Router("/error", &MainController{}, "get:Error")

	web.BConfig.Listen.HTTPPort = 4001
	web.BConfig.Listen.HTTPAddr = ""

	web.Run()
}
