from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8080

class CustomHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Hello, World!")

if __name__ == "__main__":
    with HTTPServer(("", PORT), CustomHandler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()
