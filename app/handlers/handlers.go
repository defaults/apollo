package handlers

import (
	"net/http"
)

func HellowordHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello World, Priyanka!"))
}
