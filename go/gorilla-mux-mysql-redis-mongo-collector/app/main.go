package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"time"
	"bytes"

	"github.com/XSAM/otelsql"
	"github.com/go-redis/redis/extra/redisotel/v9"
	"github.com/go-redis/redis/v9"
	_ "github.com/go-sql-driver/mysql"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"github.com/gorilla/mux"
	"go.opentelemetry.io/contrib/instrumentation/go.mongodb.org/mongo-driver/mongo/otelmongo"

	"go.opentelemetry.io/contrib/instrumentation/github.com/gorilla/mux/otelmux"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/trace"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
)

type book struct {
	ID     string `json:"ID"`
	Title  string `json:"Title"`
	Author string `json:"Author"`
}

type allBooks []book

var books = allBooks{
	{
		ID:     "1",
		Title:  "The Cockroach",
		Author: "Ian McEwan",
	},
	{
		ID:     "2",
		Title:  "Nemesis",
		Author: "Philip Roth",
	},
}

func homeLink(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)

	span := trace.SpanFromContext(r.Context())

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

	fmt.Fprintf(w, `
		<h1>Gorilla Mux test app</h1>

		<p>Available routes:<p>
		<ul>
			<li><a href="/">GET /</a></li>
			<li><a href="/slow">GET /slow</a></li>
			<li><a href="/error">GET /error</a></li>
			<li>POST /post-test</li>
			<li><a href="/books">GET /books</a></li>
			<li><a href="/books/1">GET /books/1</a></li>
			<li>PATCH /books/<id></li>
			<li>DELETE /books/<id></li>
			<li><a href="/redis-query">GET /redis-query</a></li>
			<li><a href="/mongo-query">GET /mongo-query</a></li>
			<li><a href="/mysql-query">GET /mysql-query</a></li>
		</ul>
	`)
}

func createBook(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)
	var newBook book
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Fprintf(w, "Enter data with the book title and author")
	}

	json.Unmarshal(reqBody, &newBook)
	books = append(books, newBook)
	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(newBook)
}

func getOneBook(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)
	bookID := mux.Vars(r)["id"]

	for _, singleBook := range books {
		if singleBook.ID == bookID {
			json.NewEncoder(w).Encode(singleBook)
		}
	}
}

func getAllBooks(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)
	json.NewEncoder(w).Encode(books)
}

func updateBook(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)
	bookID := mux.Vars(r)["id"]
	var updatedBook book

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Fprintf(w, "Enter data with the book title and author")
	}
	json.Unmarshal(reqBody, &updatedBook)

	for i, singleBook := range books {
		if singleBook.ID == bookID {
			singleBook.Title = updatedBook.Title
			singleBook.Author = updatedBook.Author
			books = append(books[:i], singleBook)
			json.NewEncoder(w).Encode(singleBook)
		}
	}
}

func deleteBook(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Millisecond)
	bookID := mux.Vars(r)["id"]

	for i, singleBook := range books {
		if singleBook.ID == bookID {
			books = append(books[:i], books[i+1:]...)
			fmt.Fprintf(w, "The book with ID %v has been deleted successfully", bookID)
		}
	}
}

func redisQuery(w http.ResponseWriter, r *http.Request) {
	time.Sleep(200 * time.Millisecond)
	ctx := r.Context()
	rdb := redis.NewClient(&redis.Options{
		Addr: "redis:6379",
	})

	if err := redisotel.InstrumentTracing(rdb); err != nil {
		panic(err)
	}

	if err := redisotel.InstrumentMetrics(rdb); err != nil {
		panic(err)
	}

	if err := rdb.Set(ctx, "foo", "barbaz", 0).Err(); err != nil {
		panic(err)
	}

	val, err := rdb.Get(ctx, "foo").Result()
	if err != nil {
		panic(err)
	}

	fmt.Fprintf(w, "GOT VALUE %v FROM REDIS", val)
}

func mysqlQuery(w http.ResponseWriter, r *http.Request) {
	time.Sleep(200 * time.Millisecond)
	ctx := r.Context()

	db, err := otelsql.Open(
		"mysql",
		"root:password@tcp(mysql:3306)/mydb",
		otelsql.WithAttributes(semconv.DBSystemMySQL),
	)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	rows, err := db.QueryContext(ctx, "select * from mysql.user")
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	fmt.Fprintf(w, "MYSQL QUERY LAUNCHED")
}

func mongoQuery(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	opts := options.Client()
	opts.Monitor = otelmongo.NewMonitor()
	opts.ApplyURI("mongodb://mongo:27017")
	client, err := mongo.Connect(ctx, opts)
	if err != nil {
		panic(err)
	}
	db := client.Database("example")
	inventory := db.Collection("inventory")

	_, err = inventory.InsertOne(ctx, bson.D{
		{Key: "item", Value: "canvas"},
		{Key: "qty", Value: 100},
		{Key: "attributes", Value: bson.A{"cotton"}},
		{Key: "size", Value: bson.D{
			{Key: "h", Value: 28},
			{Key: "w", Value: 35.5},
			{Key: "uom", Value: "cm"},
		}},
	})
	if err != nil {
		panic(err)
	}

	fmt.Fprintf(w, "MONGO OPERATION SUCCESSFUL")
}

func errorReq(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
}

func slowReq(w http.ResponseWriter, r *http.Request) {
	time.Sleep(3 * time.Second)
}

func postTest(w http.ResponseWriter, r *http.Request) {
	time.Sleep(200 * time.Millisecond)
	bodyParams, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}

	fmt.Fprintf(w, string(bodyParams))
}

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
		attribute.String("service.name", "gorilla-mux"),
		attribute.String("host.name", hostname),
		attribute.StringSlice("appsignal.config.filter_function_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_query_parameters", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_payload", []string{"password", "token"}),
		attribute.StringSlice("appsignal.config.filter_request_session_data", []string{"password", "token"}),
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

func recordParameters(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		span := trace.SpanFromContext(r.Context())

		// Query parameters
		requestQueryParameters := r.URL.Query()
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
		requestBodyPayload, err := ioutil.ReadAll(r.Body)
		if err != nil {
			next.ServeHTTP(w, r)
			return
		}
		r.Body = ioutil.NopCloser(bytes.NewBuffer(requestBodyPayload))
		contentType := r.Header.Get("Content-Type")
		if contentType == "application/json" {
			serializedBodyPayload = string(requestBodyPayload)
		} else if contentType == "application/x-www-form-urlencoded" {
			// Parse form-urlencoded body
			values, err := url.ParseQuery(string(requestBodyPayload))
			if err != nil {
				next.ServeHTTP(w, r)
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
			next.ServeHTTP(w, r)
			return
		}
		if len(serializedBodyPayload) > 0 {
			span.SetAttributes(attribute.String("appsignal.request.payload", serializedBodyPayload))
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	// Init OpenTelemetry
	cleanup := initTracer()
	defer cleanup(context.Background())

	router := mux.NewRouter().StrictSlash(true)
	router.Use(otelmux.Middleware("opentelemetry-go-gorillamux"))
	router.Use(recordParameters)
	router.HandleFunc("/", homeLink)
	router.HandleFunc("/book", createBook).Methods("POST")
	router.HandleFunc("/books", getAllBooks).Methods("GET")
	router.HandleFunc("/books/{id}", getOneBook).Methods("GET")
	router.HandleFunc("/books/{id}", updateBook).Methods("PATCH")
	router.HandleFunc("/books/{id}", deleteBook).Methods("DELETE")
	router.HandleFunc("/redis-query", redisQuery).Methods("GET")
	router.HandleFunc("/mongo-query", mongoQuery).Methods("GET")
	router.HandleFunc("/mysql-query", mysqlQuery).Methods("GET")
	router.HandleFunc("/error", errorReq).Methods("GET")
	router.HandleFunc("/slow", slowReq).Methods("GET")
	router.HandleFunc("/post-test", postTest).Methods("POST")
	log.Fatal(http.ListenAndServe(":4001", router))
}

func mapToJSON(m map[string]interface{}) string {
	jsonBytes, err := json.Marshal(m)
	if err != nil {
		return "{}" // Return empty JSON object on error
	}
	return string(jsonBytes)
}
