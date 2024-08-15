// main.go
package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

func main() {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)

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
	w.Write([]byte(fmt.Sprintf("CPU task completed in %s\n", duration)))
}
