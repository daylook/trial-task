package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)


func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)

	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Welcome to the Go Gin Web App!")
	})

	r.GET("/healthz", func(c *gin.Context) {
		c.String(http.StatusOK, "I am healthy!")
	})

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	return r
}

func TestHomeRoute(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "Welcome to the Go Gin Web App!", w.Body.String())
}

func TestHealthzRoute(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/healthz", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "I am healthy!", w.Body.String())
}

func TestPingRoute(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/ping", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "application/json; charset=utf-8", w.Header().Get("Content-Type"))

	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "pong", response["message"])
}

func TestNotFoundRoute(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/non-existent", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
}

func TestRoutesTableDriven(t *testing.T) {
	router := setupRouter()

	tests := []struct {
		name           string
		path           string
		expectedCode   int
		expectedBody   string
		expectedHeader string 
	}{
		{
			name:         "root endpoint",
			path:         "/",
			expectedCode: http.StatusOK,
			expectedBody: "Welcome to the Go Gin Web App!",
		},
		{
			name:         "healthz endpoint",
			path:         "/healthz",
			expectedCode: http.StatusOK,
			expectedBody: "I am healthy!",
		},
		{
			name:           "ping endpoint",
			path:           "/ping",
			expectedCode:   http.StatusOK,
			expectedBody:   `{"message":"pong"}`,
			expectedHeader: "application/json; charset=utf-8",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			req, _ := http.NewRequest("GET", tt.path, nil)
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedCode, w.Code)

			if tt.expectedHeader != "" {
				assert.Equal(t, tt.expectedHeader, w.Header().Get("Content-Type"))
			}

			actualBody := w.Body.String()
			if tt.expectedBody != "" {
				if tt.path == "/ping" {
					assert.JSONEq(t, tt.expectedBody, actualBody)
				} else {
					assert.Equal(t, tt.expectedBody, actualBody)
				}
			}
		})
	}
}
