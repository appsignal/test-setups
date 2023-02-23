package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/astaxie/beego"
	"go.opentelemetry.io/contrib/instrumentation/github.com/astaxie/beego/otelbeego"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

type exampleController struct {
	beego.Controller
}

func (c *exampleController) Get() {
	time.Sleep(100 * time.Millisecond)
	ctx := c.Ctx.Request.Context()
	span := trace.SpanFromContext(ctx)
	span.AddEvent("handling this...")
	c.Ctx.WriteString("Hello, world!")
}

func (c *exampleController) Template() {
	time.Sleep(100 * time.Millisecond)
	c.TplName = "hello.tpl"
	// Render the template file with tracing enabled
	if err := otelbeego.Render(&c.Controller); err != nil {
		c.Abort("500")
	}
}

func newConsoleExporter() (sdktrace.SpanExporter, error) {
	return stdouttrace.New(
		stdouttrace.WithWriter(os.Stdout),
		stdouttrace.WithPrettyPrint(),
		stdouttrace.WithoutTimestamps(),
	)
}

func initTracer() (*sdktrace.TracerProvider, error) {
	client := otlptracehttp.NewClient(
		otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint("0.0.0.0:8099"),
	)
	exporter, err := otlptrace.New(context.Background(), client)
	if err != nil {
		log.Fatal("creating OTLP trace exporter: %w")
	}

	consoleExporter, err := newConsoleExporter()
	if err != nil {
		log.Fatal("creating OTLP console exporter: %w")
	}

	// For the demonstration, use sdktrace.AlwaysSample sampler to sample all traces.
	// In a production application, use sdktrace.ProbabilitySampler with a desired probability.
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
		sdktrace.WithBatcher(exporter),
		sdktrace.WithBatcher(consoleExporter),
	)
	otel.SetTracerProvider(tp)
	// otel.SetTracerProvider(consoleTracerProvider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
	return tp, nil
}

func main() {
	tp, err := initTracer()
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := tp.Shutdown(context.Background()); err != nil {
			log.Printf("Error shutting down tracer provider: %v", err)
		}
	}()

	// To enable tracing on template rendering, disable autorender
	beego.BConfig.WebConfig.AutoRender = false

	beego.Router("/hello", &exampleController{})
	beego.Router("/", &exampleController{}, "get:Template")

	mware := otelbeego.NewOTelBeegoMiddleWare("beego-example")

	beego.RunWithMiddleWares(":8080", mware)
}
