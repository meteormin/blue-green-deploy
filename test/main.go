package main

import (
	"log"
	"net/http"
	"time"
)

var (
	count = 10
	delay = time.Second * 5
)

func main() {
	log.Println("start blue-green deploy test")
	for i := 0; i < count; i++ {
		log.Println("health check", i)
		healthCheck()
		time.Sleep(delay)
	}
}

func healthCheck() {
	resp, err := http.Get("http://localhost/api/health")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Fatal("health check failed", resp.StatusCode)
	}
}
