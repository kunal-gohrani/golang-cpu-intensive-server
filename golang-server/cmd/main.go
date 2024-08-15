// main.go
package main

import (
	"crypto/subtle"
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

	r.Use(BasicAuth("admin", "passworddddddddd"))

	// Routes
	r.Get("/rest/v1/iotime", IOTaskHandler)

	// Start Server
	http.ListenAndServe(":8080", r)
}

// BasicAuth middleware for simple username/password authentication
func BasicAuth(username, password string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			u, p, ok := r.BasicAuth()
			if !ok || subtle.ConstantTimeCompare([]byte(u), []byte(username)) != 1 || subtle.ConstantTimeCompare([]byte(p), []byte(password)) != 1 {
				w.Header().Set("WWW-Authenticate", `Basic realm="restricted"`)
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
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
