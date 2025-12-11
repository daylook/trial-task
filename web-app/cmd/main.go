package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)


func main() {

	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Welcome to the Go Gin Web App!")
	})

	r.GET("/healthz", func(c *gin.Context) {
		c.String(http.StatusOK, "I am healthy!")
	})

	r.GET("/ready", func(c *gin.Context) {
		c.String(http.StatusOK, "I am ready!")
	})

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
