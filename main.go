package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

const slugLength = 6

var db *sql.DB

func init() {
	rand.Seed(time.Now().UnixNano())
	var err error
	dbConnStr := os.Getenv("DATABASE_URL") // "postgres://user:password@db:5432/url_shortener?sslmode=disable"
	if dbConnStr == "" {
		log.Fatal("DATABASE_URL environment variable is not set")
	}

	db, err = sql.Open("postgres", dbConnStr)
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS urls (
		slug TEXT PRIMARY KEY,
		long_url TEXT NOT NULL
	)`)
	if err != nil {
		log.Fatal(err)
	}
}

func generateSlug() string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	result := make([]byte, slugLength)
	for i := range result {
		result[i] = charset[rand.Intn(len(charset))]
	}
	return string(result)
}

func shortenURL(c *gin.Context) {
	var req struct {
		LongURL string `json:"long_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	slug := generateSlug()
	_, err := db.Exec("INSERT INTO urls (slug, long_url) VALUES ($1, $2)", slug, req.LongURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not shorten URL"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"short_url": fmt.Sprintf("http://localhost:8080/%s", slug)})
}

func resolveURL(c *gin.Context) {
	slug := c.Param("slug")
	var longURL string
	err := db.QueryRow("SELECT long_url FROM urls WHERE slug = $1", slug).Scan(&longURL)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "URL not found"})
		return
	}
	c.Redirect(http.StatusFound, longURL)
}

func main() {
	r := gin.Default()
	r.POST("/shorten", shortenURL)
	r.GET("/:slug", resolveURL)

	log.Println("Server running on :8080")
	r.Run(":8080")
}
