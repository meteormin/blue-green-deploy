package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

var startDelay = time.Second * 10

type Health struct {
	Status bool `json:"status"`
}

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		log.Println("health check")

		w.Header().Set("Content-Type", "application/json")

		jsonBytes, err := json.Marshal(Health{Status: true})
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
		}

		w.WriteHeader(http.StatusOK)
		w.Write(jsonBytes)
	})

	// 테스트를 위한 실행 대기
	time.Sleep(startDelay)

	port := "8080"

	log.Printf("Listening on port %s...", port)

	log.Fatal(http.ListenAndServe(":"+port, nil))
}
