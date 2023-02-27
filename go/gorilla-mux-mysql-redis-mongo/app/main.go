package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

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
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
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
	fmt.Fprintf(w, "Welcome home!")
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
		otlptracehttp.WithEndpoint("appsignal:8099"),
	)
	exporter, err := otlptrace.New(context.Background(), client)
	if err != nil {
		log.Fatal("creating OTLP trace exporter: %w")
	}

	consoleExporter, err := newConsoleExporter()
	if err != nil {
		log.Fatal("creating OTLP console exporter: %w")
	}

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
		sdktrace.WithBatcher(exporter),
		sdktrace.WithBatcher(consoleExporter),
	)
	otel.SetTracerProvider(tracerProvider)
	return exporter.Shutdown
}

func main() {
	// Init OpenTelemetry
	cleanup := initTracer()
	defer cleanup(context.Background())

	router := mux.NewRouter().StrictSlash(true)
	router.Use(otelmux.Middleware("opentelemetry-go-gorillamux"))
	router.HandleFunc("/", homeLink)
	router.HandleFunc("/book", createBook).Methods("POST")
	router.HandleFunc("/books", getAllBooks).Methods("GET")
	router.HandleFunc("/books/{id}", getOneBook).Methods("GET")
	router.HandleFunc("/books/{id}", updateBook).Methods("PATCH")
	router.HandleFunc("/books/{id}", deleteBook).Methods("DELETE")
	router.HandleFunc("/redis-query", redisQuery).Methods("GET")
	router.HandleFunc("/mongo-query", mongoQuery).Methods("GET")
	router.HandleFunc("/mysql-query", mysqlQuery).Methods("GET")
	log.Fatal(http.ListenAndServe(":4001", router))
}
