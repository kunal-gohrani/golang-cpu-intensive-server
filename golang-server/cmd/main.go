// main.go
package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

var hostname string = ""

type ctxKey string

var hostnameCtxKey ctxKey = "hostname"

func init() {
	hostname, _ = os.Hostname()
}

func addHostNameMiddleware(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		ctx = context.WithValue(ctx, hostnameCtxKey, hostname)
		r = r.WithContext(ctx)
		h.ServeHTTP(w, r)
	})
}

func main() {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(addHostNameMiddleware)
	// CORS Middleware
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"}, // Allow all origins
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: false,
		MaxAge:           300, // Max value for preflight request cache
	}))

	// Routes
	r.Get("/rest/v1/iotime", IOTaskHandler)

	// Start Server
	http.ListenAndServe(":8080", r)
}

// IOTaskHandler simulates a CPU-intensive task
func IOTaskHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	// Simulate CPU load
	for i := 0; i < 1000000000; i++ {
		_ = i * i
	}

	duration := time.Since(start)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(fmt.Sprintf("CPU task completed in %s by host %s\n", duration, r.Context().Value(hostnameCtxKey))))
}
