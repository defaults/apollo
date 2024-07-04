package main

import "net/http"

func main() {
	http.HandleFunc("/", hellowordhandler)

	http.ListenAndServe(":9000", nil)
}

func hellowordhandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello World"))
}
